function [C,timingfile,userdefined_trialholder] = evoStimBigGAN_userloop(MLConfig,TrialRecord) %#ok<INUSL>
% evoStimBigGAN_userloop  Closed-loop image evolution with BigGAN, scored by
% online firing rates from the RHX FR server (96-channel Utah array).
%
% ------------------------------------------------------------------------
% WHAT HAPPENS
%   One block = 5 conditions x 10 images
%             = 40 BigGAN images (conditions 1-4) + 10 natural controls (condition 5).
%   Each trial (timing file evoStimTCP.m, unchanged) shows the 10 images of
%   one condition and sends a TTL at every image onset. A condition repeats
%   until the monkey completes it (error 0), then the next condition follows.
%   When all 5 conditions are completed:
%     1) pull the NCH x nTTL firing-rate matrix from the FR server
%     2) keep only TTLs from successful trials -> 50 images
%     3) score = mean FR(excitatory ch) - mean FR(inhibitory ch)
%     4) save everything for this block (codes, scores, raw FR, trial log)
%     5) CMA-ES update with the 40 synthetic scores (natural images not used)
%     6) sample 40 new codes, render them with BigGAN, save the PNGs
%   Block 1 always uses the fixed codes in biggan_init.mat
%   (created once by make_biggan_init.m), so every session starts identically.
%
% SAVED IN THE SESSION FOLDER  (<yymmdd_HHMMSS>__biggan_evol_stimuli)
%   settings.mat          all settings of this session
%   biggan_init.mat       copy of the starting point used
%   codes_blk%03d.mat     codes of each block (saved when rendered)
%   blk%03d_img_%03d.png  all images shown (1-40 synthetic, 41-50 natural)
%   blk%03d_data.mat      per block: codes, scores, raw FR (all channels),
%                         trial log, TTL bookkeeping, optimizer state
%   session_all.mat       cumulative logs, overwritten after every block
%   *.png figures         at the end of the session
%
% FILES NEEDED ON THE PATH
%   evoStimTCP.m, BigGAN_CMAES.m, build_block_images_biggan.m,
%   compute_block_scores.m, block_repr_image_biggan.m, rhx_global_chan.m,
%   pull_FR_matrix.m, send_FR_end_task.m, plot_session_summary.m,
%   load_biggan.m + generate_biggan.m (+ biggan256_initialized_V2.mat) in BIGGAN_DIR,
%   biggan_init.mat and natural_images.mat in the task folder.
% ------------------------------------------------------------------------

C = [];
timingfile = 'evoStimTCP.m';      % same timing file as the XDream version
userdefined_trialholder = '';

% MonkeyLogic calls the userloop once before Trial 1 only to get the timing
% file name. Return early that first time; initialization happens on the
% second call.
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

%% ===================== SETTINGS (edit per experiment) =====================
% ---- BigGAN ----
BIGGAN_DIR = pwd;   % BigGAN files live in the current (task) folder
USE_GPU    = true;                  % render on the GPU
GEN_BATCH  = 40;                    % images per GPU batch (lower it if block 1 gives a GPU memory error)
INIT_FILE  = 'biggan_init.mat';     % fixed starting point (make_biggan_init.m)
NAT_FILE   = 'natural_images.mat';  % natural controls (field NAMES)

% ---- Visual stimulus ----
fix      = [0 0];
img_loc  = [-5.0 -1.5];
pxperdeg = 36.039;
img_size = [9 9]*pxperdeg;

% ---- Design ----
IMGS_PER_BLOCK    = 40;   % BigGAN images per block (= CMA-ES population)
NatIMGS_PER_BLOCK = 10;   % natural control images per block
IMGS_PER_COND     = 10;   % images per trial (one condition)
N_COND            = (IMGS_PER_BLOCK + NatIMGS_PER_BLOCK)/IMGS_PER_COND;  % 4 + 1 = 5
N_TOT             = IMGS_PER_BLOCK + NatIMGS_PER_BLOCK;                 % 50
MAX_BLOCKS        = 50;

% ---- FR server ----
fr_server_ip   = '10.68.14.139';
fr_server_port = 6010;
FR_PULL_DELAY  = 0.3;     % s. The server only finalizes a TTL once its window
                          % (winEnd 0.205 s + 0.010 s margin) has streamed in.
                          % The last image's window can still be open when the
                          % userloop runs, so wait before asking for the FRs.

% ===== Select channels for closed-loop feedback =====
fr_chan_exc = {'A27', 'B31'};
fr_chan_inh = {'B18'};

% Combine selected channels
fr_selected_ch = [fr_chan_exc, fr_chan_inh];

% Sort channels by port (A, B, C, D), then channel number
port_num = zeros(1, numel(fr_selected_ch));
chan_num = zeros(1, numel(fr_selected_ch));

for k = 1:numel(fr_selected_ch)
    ch = upper(fr_selected_ch{k});
    port_num(k) = double(ch(1)) - double('A');
    chan_num(k) = str2double(ch(2:end));
end

[~, sort_idx] = sortrows([port_num(:), chan_num(:)], [1 2]);

fr_server_ch = fr_selected_ch(sort_idx);

% Find row indices for excitation and inhibition
fr_rows_exc = find(ismember(fr_server_ch, fr_chan_exc));
fr_rows_inh = find(ismember(fr_server_ch, fr_chan_inh));

% Number of channels expected from server
NCH = numel(fr_server_ch);

% Save information
TrialRecord.User.NCH = NCH;
TrialRecord.User.fr_chan_exc = fr_chan_exc;
TrialRecord.User.fr_chan_inh = fr_chan_inh;
TrialRecord.User.fr_server_ch = fr_server_ch;

persistent printChannels
if isempty(printChannels)
    fprintf('Expected FR channels (%d): %s\n', ...
        NCH, strjoin(fr_server_ch, ', '));
    
    fprintf('Excitation rows: %s\n', mat2str(fr_rows_exc));
    fprintf('Inhibition rows: %s\n', mat2str(fr_rows_inh));
    printChannels = 1;
end

% Values read by the timing file / userplot
TrialRecord.User.N_COND        = N_COND;
TrialRecord.User.IMGS_PER_COND = IMGS_PER_COND;

% Variables written to session_all.mat (after every block and at the end)
SESSION_VARS = {'codes_all','scores_all','generations','names_all','img_type_all', ...
                'img_traj','FR_all','sigma_hist','fr_chan_exc','fr_chan_inh'};

%% ===================== PERSISTENT STATE =====================
persistent init_done
persistent G optim                         % BigGAN generator, CMA-ES optimizer
persistent codes_block                     % [40 x 256] codes shown in the CURRENT block
persistent block_image_names               % [50 x 1]  relative paths, CURRENT block
persistent block_cond_names                % [5 x 10]  names grouped by condition
persistent nat_names_block_in              % [10 x 1]  natural image source files
persistent cond_order cond_ptr current_block_idx
persistent OUT_DIR OUT_DIR_REL
% ---- logs across blocks ----
persistent codes_all                       % [40*nBlocks x 256]
persistent scores_all                      % [50*nBlocks x 3]: score, score_exc, score_inh
persistent generations                     % [50*nBlocks x 1]  block number of each row of scores_all
persistent names_all                       % [50*nBlocks x 1]  image file of each row
persistent img_type_all                    % [50*nBlocks x 1]  0 = synthetic, 1 = natural
persistent img_traj                        % {MAX_BLOCKS} representative image per block
persistent FR_all                          % {MAX_BLOCKS} raw NCH x nTTL FR matrix per block
persistent sigma_hist                      % [MAX_BLOCKS x 1] CMA-ES sigma used to sample each block
% ---- trial bookkeeping within the CURRENT block ----
persistent block_trial_log                 % struct: cond_idx, err_code, had_ttl, ttl_count
persistent last_logged_trial_count         % trials already logged
persistent last_returned_cond_idx          % condition returned on the previous call

%% ===================== ONE-TIME INIT =====================
if isempty(init_done)
    % ---- 1) session output folder ----
    OUT_DIR_REL = [datestr(now,'yymmdd_HHMMSS') '__biggan_evol_stimuli'];
    OUT_DIR     = fullfile(pwd, OUT_DIR_REL);
    if ~exist(OUT_DIR, 'dir'), mkdir(OUT_DIR); end

    % ---- 2) BigGAN ----
    addpath(BIGGAN_DIR);
    G = load_biggan();
    if USE_GPU && ~canUseGPU()
        error('USE_GPU = true, but MATLAB cannot use a GPU on this PC.');
    end

    % ---- 3) fixed starting point ----
    if ~exist(INIT_FILE, 'file')
        error('%s not found. Run make_biggan_init.m once from the task folder first.', INIT_FILE);
    end
    I = load(INIT_FILE);
    if ~isequal(size(I.init_codes), [IMGS_PER_BLOCK 256])
        error('%s holds %dx%d codes, but IMGS_PER_BLOCK = %d (needs %dx256).', ...
              INIT_FILE, size(I.init_codes,1), size(I.init_codes,2), IMGS_PER_BLOCK, IMGS_PER_BLOCK);
    end
    copyfile(INIT_FILE, OUT_DIR);                  % keep the starting point with the session
    optim       = BigGAN_CMAES(I.init_z, I.init_sigma, IMGS_PER_BLOCK);
    codes_block = double(I.init_codes);
    optim.setPopulation(codes_block);              % block 1 = fixed codes, not a new random draw

    % ---- 4) natural control images ----
    S_nat = load(NAT_FILE);
    nat_names_block_in = S_nat.NAMES(1:NatIMGS_PER_BLOCK);
    nat_names_block_in = nat_names_block_in(:);

    % ---- 5) render block 1 (also tells you the pause between blocks) ----
    generate_biggan(G, codes_block(1,:), USE_GPU, 1);   % GPU warm-up: the first call is slow
    [block_image_names, block_cond_names, t_render] = build_block_images_biggan( ...
        G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1, ...
        nat_names_block_in, USE_GPU, GEN_BATCH);
    fprintf('[BigGAN] Block 1 ready: rendering + saving took %.2f s (about the pause between blocks).\n', t_render);

    % ---- 6) logs ----
    codes_all    = [];
    scores_all   = [];
    generations  = [];
    names_all    = {};
    img_type_all = [];
    img_traj     = cell(MAX_BLOCKS, 1);
    FR_all       = cell(MAX_BLOCKS, 1);
    sigma_hist   = nan(MAX_BLOCKS, 1);
    sigma_hist(1) = optim.sigma;
    img_traj{1}  = block_repr_image_biggan(G, codes_block, block_image_names(1:IMGS_PER_BLOCK), USE_GPU);

    % ---- 7) schedule and trial bookkeeping ----
    cond_order        = 1:N_COND;
    cond_ptr          = 1;
    current_block_idx = 1;
    block_trial_log   = struct('cond_idx', {}, 'err_code', {}, 'had_ttl', {}, 'ttl_count', {});
    last_logged_trial_count = 0;
    last_returned_cond_idx  = [];

    % ---- 8) save the settings of this session ----
    settings = struct();
    settings.BIGGAN_DIR        = BIGGAN_DIR;
    settings.USE_GPU           = USE_GPU;
    settings.GEN_BATCH         = GEN_BATCH;
    settings.INIT_FILE         = INIT_FILE;
    settings.init_sigma        = I.init_sigma;
    settings.NAT_FILE          = NAT_FILE;
    settings.nat_names         = nat_names_block_in;
    settings.fix               = fix;
    settings.img_loc           = img_loc;
    settings.img_size          = img_size;
    settings.IMGS_PER_BLOCK    = IMGS_PER_BLOCK;
    settings.NatIMGS_PER_BLOCK = NatIMGS_PER_BLOCK;
    settings.IMGS_PER_COND     = IMGS_PER_COND;
    settings.N_COND            = N_COND;
    settings.MAX_BLOCKS        = MAX_BLOCKS;
    settings.fr_server_ip      = fr_server_ip;
    settings.fr_server_port    = fr_server_port;
    settings.NCH               = NCH;
    settings.FR_PULL_DELAY     = FR_PULL_DELAY;
    settings.fr_chan_exc       = fr_chan_exc;
    settings.fr_chan_inh       = fr_chan_inh;
    settings.fr_server_ch      = fr_server_ch;
    settings.fr_rows_exc       = fr_rows_exc;
    settings.fr_rows_inh       = fr_rows_inh;
    save(fullfile(OUT_DIR, 'settings.mat'), 'settings');

    init_done = true;
end

%% ===================== EARLY QUIT =====================
quit_now = (isprop(TrialRecord,'Quit') || isfield(TrialRecord,'Quit')) && TrialRecord.Quit;
if quit_now
    send_FR_end_task(fr_server_ip, fr_server_port);
    save(fullfile(OUT_DIR, 'session_all.mat'), SESSION_VARS{:});
    plot_session_summary(img_traj, generations, scores_all, img_type_all, OUT_DIR);
    C = {sprintf('fix(%d,%d)', fix(1), fix(2))};
    TrialRecord.NextBlock = -1;
    TrialRecord.NextCondition = 1;
    return
end

%% ===================== LOG THE PREVIOUS TRIAL(S) =====================
% TrialRecord.TrialErrors grows by one after each trial. For each new trial,
% record which condition it was, its error code, and how many TTLs it sent
% (num_TTL is written by the timing file). Errors 0/3/4 sent TTLs; 1/2 did not.
ntr_done = numel(TrialRecord.TrialErrors);
if ntr_done > last_logged_trial_count
    for tr = (last_logged_trial_count+1):ntr_done
        err_code = TrialRecord.TrialErrors(tr);
        if isempty(last_returned_cond_idx)
            this_cond = cond_order(min(cond_ptr, N_COND));   % guard, should not happen
        else
            this_cond = last_returned_cond_idx;
        end
        block_trial_log(end+1).cond_idx = this_cond; %#ok<AGROW>
        block_trial_log(end).err_code   = err_code;
        block_trial_log(end).had_ttl    = ismember(err_code, [0 3 4]);
        block_trial_log(end).ttl_count  = double(TrialRecord.User.num_TTL);
    end
    last_logged_trial_count = ntr_done;
end

%% ===================== POINTER UPDATE =====================
% Advance to the next condition only after a successful trial.
if ~isempty(TrialRecord.TrialErrors) && TrialRecord.TrialErrors(end) == 0
    cond_ptr = cond_ptr + 1;
end

%% ===================== END OF BLOCK =====================
if cond_ptr > N_COND
    blk      = current_block_idx;
    blk_file = fullfile(OUT_DIR, sprintf('blk%03d_data.mat', blk));

    % ---- 1) firing rates from the server ----
    pause(FR_PULL_DELAY);
    [FR, ~, ~] = pull_FR_matrix(fr_server_ip, fr_server_port);   % NCH x nTTL

    % ---- 2) align TTLs to images and score ----
    try
        % sc = compute_block_scores(FR, block_trial_log, fr_chan_exc, fr_chan_inh, ...
        %                           NCH, N_COND, IMGS_PER_COND);
        sc = compute_block_scores(FR, block_trial_log, fr_rows_exc, fr_rows_inh, ...
                          NCH, N_COND, IMGS_PER_COND);
    catch ME
        % Save the raw data before stopping, so nothing is lost
        FR_raw = FR; trial_log = block_trial_log; %#ok<NASGU>
        codes = codes_block; image_names = block_image_names; %#ok<NASGU>
        save(fullfile(OUT_DIR, sprintf('blk%03d_FAILED.mat', blk)), ...
             'FR_raw', 'trial_log', 'codes', 'image_names');
        fprintf(2, '[Block %d] Scoring failed; raw data saved to blk%03d_FAILED.mat\n', blk, blk);
        rethrow(ME);
    end

    % ---- 3) save everything about this block ----
    blockData = struct();
    blockData.block_idx        = blk;
    blockData.codes            = codes_block;           % 40 x 256 (rows = images 1-40)
    blockData.image_names      = block_image_names;     % 50 x 1
    blockData.scores           = sc.scores;             % 1 x 50 (exc - inh)
    blockData.scores_exc       = sc.scores_exc;
    blockData.scores_inh       = sc.scores_inh;
    blockData.FR_img           = sc.FR_img;             % 96 x 50, all channels per image
    blockData.FR_raw           = FR;                    % 96 x nTTL, as received
    blockData.err_per_ttl      = sc.err_per_ttl;
    blockData.cond_idx_per_ttl = sc.cond_idx_per_ttl;
    blockData.keep_mask        = sc.keep_mask;
    blockData.trial_log        = block_trial_log;
    blockData.fr_chan_exc      = fr_chan_exc;
    blockData.fr_chan_inh      = fr_chan_inh;
    blockData.sigma            = sigma_hist(blk);       % sigma used to sample this block
    save(blk_file, '-struct', 'blockData');

    % ---- 4) cumulative logs ----
    codes_all    = [codes_all;    codes_block];
    scores_all   = [scores_all;   [sc.scores(:) sc.scores_exc(:) sc.scores_inh(:)]];
    generations  = [generations;  blk*ones(N_TOT, 1)];
    names_all    = [names_all;    block_image_names(:)];
    img_type_all = [img_type_all; [zeros(IMGS_PER_BLOCK,1); ones(NatIMGS_PER_BLOCK,1)]];
    FR_all{blk}  = FR;
    TrialRecord.User.scores_all  = scores_all;
    TrialRecord.User.generations = generations;

    fprintf('[Block %d] synthetic mean %.2f, max %.2f | natural mean %.2f (score, spikes/s)\n', ...
        blk, mean(sc.scores(1:IMGS_PER_BLOCK)), max(sc.scores(1:IMGS_PER_BLOCK)), ...
        mean(sc.scores(IMGS_PER_BLOCK+1:end)));

    % ---- 5) last block: save, stop the server, plot, end ----
    if blk >= MAX_BLOCKS
        save(fullfile(OUT_DIR, 'session_all.mat'), SESSION_VARS{:});
        send_FR_end_task(fr_server_ip, fr_server_port);
        plot_session_summary(img_traj, generations, scores_all, img_type_all, OUT_DIR);
        C = {sprintf('fix(%d,%d)', fix(1), fix(2))};
        TrialRecord.NextBlock = -1;
        TrialRecord.NextCondition = 1;
        return
    end

    % ---- 6) CMA-ES update with the 40 synthetic scores ----
    optim.tell(codes_block, sc.scores(1:IMGS_PER_BLOCK));
    optim_state = optim.getState(); %#ok<NASGU>
    save(blk_file, 'optim_state', '-append');
    sigma_hist(blk+1) = optim.sigma;
    TrialRecord.User.sigma = optim.sigma;
    save(fullfile(OUT_DIR, 'session_all.mat'), SESSION_VARS{:});

    % ---- 7) sample and render the next block ----
    next_blk    = blk + 1;
    codes_block = optim.ask();                     % 40 x 256 new codes
    [block_image_names, block_cond_names, t_render] = build_block_images_biggan( ...
        G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, next_blk, ...
        nat_names_block_in, USE_GPU, GEN_BATCH);
    img_traj{next_blk} = block_repr_image_biggan(G, codes_block, block_image_names(1:IMGS_PER_BLOCK), USE_GPU);
    fprintf('[Block %d] ready in %.2f s (sigma = %.4f)\n', next_blk, t_render, optim.sigma);

    % ---- 8) reset the per-block bookkeeping ----
    current_block_idx = next_blk;
    cond_order        = 1:N_COND;
    cond_ptr          = 1;
    block_trial_log   = struct('cond_idx', {}, 'err_code', {}, 'had_ttl', {}, 'ttl_count', {});
    last_logged_trial_count = numel(TrialRecord.TrialErrors);
    last_returned_cond_idx  = [];
end

%% ===================== RETURN THE NEXT TRIAL'S TaskObjects =====================
cond_idx   = cond_order(cond_ptr);           % 1..5 (5 = natural controls)
names_cond = block_cond_names(cond_idx, :);  % 1 x 10 file names

% TaskObject #1 = fixation, #2..#11 = the 10 images of this condition
C = {sprintf('fix(%d,%d)', fix(1), fix(2))};
for k = 1:IMGS_PER_COND
    C{end+1} = sprintf('pic(%s,%f,%f,%f,%f)', names_cond{k}, ...
        img_loc(1), img_loc(2), img_size(1), img_size(2)); %#ok<AGROW>
end

% Remember the condition of THIS trial (it is logged on the next call)
last_returned_cond_idx = cond_idx;

TrialRecord.NextBlock     = current_block_idx;
TrialRecord.NextCondition = cond_idx;

% For the userplot
TrialRecord.User.scores_all        = scores_all;
TrialRecord.User.generations       = generations;
TrialRecord.User.IMGS_PER_BLOCK    = IMGS_PER_BLOCK;
TrialRecord.User.NatIMGS_PER_BLOCK = NatIMGS_PER_BLOCK;
end
