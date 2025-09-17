function [C,timingfile,userdefined_trialholder] = evoStimTCP_userloop(MLConfig,TrialRecord)
% evoStimTCP_userloop  (FR-driven scoring version)
% - 4 conditions per block; each trial shows 10 images of that condition.
% - Scores per block are derived from RHX FR server (32×N matrix), not AlexNet.
% - We only use FRs from trials with error==0 (successful) and map each success trial's FR
%   to its 10 images. Trials with errors 3 or 4 still send TTLs (contribute to N)
%   but are ignored when forming the 40-length score vector (except for alignment).
% - AlexNet code is preserved but commented out.

% ---- outputs ----
C = [];
timingfile = 'evoStimTCP.m';
userdefined_trialholder = '';

% ---- ML calls userloop twice before Trial 1; return early the first time ----
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

% ============== Visual stimulus properties ==============
fix = [0 0];
img_loc = [-10 +2];
pxperdeg = 36.039;
img_size = [16 16]*pxperdeg;

% =================== Design constants ===================
IMGS_PER_BLOCK = 40;                 % 4 conditions × 10 images
NatIMGS_PER_BLOCK = 10;
IMGS_PER_COND  = 10;
N_COND         = IMGS_PER_BLOCK/IMGS_PER_COND + NatIMGS_PER_BLOCK/IMGS_PER_COND;  % 4 + 1 = 5
MAX_BLOCKS     = 10;

TrialRecord.User.N_COND = N_COND;

% ===== FR SERVER (client) =====
fr_server_ip   = '10.68.15.125';
fr_server_port = 6010;              % matches your server
fr_chan        = 4;                % electrode index 0..31  (row = fr_chan+1)

% ===== AlexNet (kept for reference; now commented) =====
% alex_layer         = 'fc6';
% alex_iChan         = 2;
% alex_iChan_inh     = 2;

% =================== Persistent state ===================
persistent init_done
persistent G net optim
persistent codes_block                      % [40 x 4096] codes that produced CURRENT block
persistent block_image_names                % [40 x 1] relative paths for CURRENT block
persistent block_cond_names                 % [4 x 10]  names grouped by condition
persistent cond_order cond_ptr              % randomized order and pointer within block
persistent current_block_idx                % 1..MAX_BLOCKS
persistent use_names_firstblock             % true if block 1 used S.NAMES
persistent OUT_DIR OUT_DIR_REL
persistent codes_all scores_all generations img_traj names_all
persistent nat_names_block_in

% ----- trial-level bookkeeping within CURRENT block -----
persistent block_trial_log                  % struct array with fields: cond_idx, err_code, had_ttl
persistent ttl_trial_positions              % positions (within block_trial_log) for TTL trials, in order
persistent last_logged_trial_count          % how many trials we have logged so far (to detect new one)
persistent last_returned_cond_idx           % cond_idx we returned in the previous call (to log on next call)

% =================== One-time init ===================
if isempty(init_done)
    % --- Create timestamped output folder ---
    stamp_folder = [datestr(now,'yymmdd_HHMMSS') '__evol_stimuli'];
    OUT_DIR = fullfile(pwd, stamp_folder);
    if ~exist(OUT_DIR,'dir'), mkdir(OUT_DIR); end
    OUT_DIR_REL = stamp_folder;

    % --- Load generator / model (optional NAMES-only ok) ---
    G   = FC6Generator('matlabGANfc6.mat');
       % net = alexnet();
    
    opts   = struct('init_sigma',3.0,'popsize',IMGS_PER_BLOCK);
    optim  = CMAES_simple(4096, [], opts);
    

    % --- Seed codes / names (prefer images.mat) ---
    codes_block = [];
    use_names_firstblock = false;

    if exist(fullfile(pwd,'images.mat'),'file')
        S_nat = load(fullfile(pwd,'natural_images.mat'));
        S = load(fullfile(pwd,'images.mat'));
        % block 1 from NAMES if available
        if isfield(S,'NAMES') && iscell(S.NAMES) && numel(S.NAMES) >= IMGS_PER_BLOCK
            idx_names      = 1:IMGS_PER_BLOCK;
            names_block_in = S.NAMES(idx_names);
            idx_nat_names  = 1:NatIMGS_PER_BLOCK;
            nat_names_block_in = S_nat.NAMES(idx_nat_names);

            [block_image_names, block_cond_names] = build_block_from_names([names_block_in; nat_names_block_in], OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1);
            use_names_firstblock = true;
            % === tie codes_block to the EXACT rows that fed names_block_in ===
            codes_mat = [];
            if isfield(S,'codes'), codes_mat = S.codes; end       % your generator saved 'codes'
            codes_block = double(codes_mat(idx_names,:));   % <-- first 40 rows aligned to NAMES
            %disp(size(codes_block))
            
        end
        
    end


    % --- Schedule & counters ---
    cond_order = 1:N_COND; %randperm(N_COND);
    cond_ptr   = 1;
    current_block_idx = 1;

    % --- logs across blocks ---
    codes_all = [];
    scores_all = [];
    generations = [];
    img_traj = cell(MAX_BLOCKS,1);
    names_all = {};

    % --- per-block bookkeeping init ---
    block_trial_log = struct('cond_idx', {}, 'err_code', {}, 'had_ttl', {}, 'ttl_count', {});
    ttl_trial_positions = [];
    last_logged_trial_count = 0;
    last_returned_cond_idx = []; % we will set it when we output C below

    % representative for block 1
    img_traj{1} = block_repr_image(G, codes_block, block_image_names(1:IMGS_PER_BLOCK));

    init_done = true;
end

% ===== EARLY QUIT (user pressed Stop/Q) =====
if isfield(TrialRecord,'Quit') && TrialRecord.Quit
    % Tell FR server to end (use your same code path; fix var name!)
    t_socket = [];
    if isempty(t_socket) || ~isvalid(t_socket)
        t_socket = tcpclient(fr_server_ip, fr_server_port, "Timeout", 5);
        configureTerminator(t_socket, "LF");
    end
    writeline(t_socket, "End_Task");  % <— was 't' before; use t_socket

    % Save what you have so far
    try, save(fullfile(OUT_DIR_REL,'codes_all.mat'),   'codes_all','-v7.3');   end
    try, save(fullfile(OUT_DIR_REL,'scores_all.mat'),  'scores_all','-v7.3');  end
    try, save(fullfile(OUT_DIR_REL,'generations.mat'), 'generations','-v7.3'); end
    try, save(fullfile(OUT_DIR_REL,'img_traj.mat'),    'img_traj','-v7.3');    end
    try, save(fullfile(OUT_DIR_REL,'names_all.mat'),   'names_all','-v7.3');   end

    try
        figure; montage(img_traj(~cellfun(@isempty,img_traj))); title('Block representatives');
        xlabel('Generation'); ylabel('activation');
    catch, end
    try
        figure; scatter(generations, scores_all); xlabel('Generation'); ylabel('FR score'); title('Scores by block');
    catch, end

    C = {sprintf('fix(%d,%d)', fix(1), fix(2))};   % graceful end
    TrialRecord.NextBlock = -1;  %#ok<NASGU>
    TrialRecord.NextCondition = 1; %#ok<NASGU>
    return
end


% =================== LOG the PREVIOUS trial (if any new) ===================
% MonkeyLogic increments TrialRecord.TrialErrors after a trial finishes.
ntr_done = numel(TrialRecord.TrialErrors);
if ntr_done > last_logged_trial_count
    % there might be >1 new (rare); handle all new ones
    for tr = (last_logged_trial_count+1) : ntr_done
        err_code = TrialRecord.TrialErrors(tr);
        
        % We rely on last_returned_cond_idx from the moment we prepared that trial
        if isempty(last_returned_cond_idx)
            % should not happen after first actual trial, but guard anyway
            this_cond = cond_order( min(cond_ptr, N_COND) );
        else
            this_cond = last_returned_cond_idx;
        end
        had_ttl = ismember(err_code, [0 3 4]);

        block_trial_log(end+1).cond_idx = this_cond; %#ok<SAGROW>
        block_trial_log(end  ).err_code = err_code;
        block_trial_log(end  ).had_ttl  = had_ttl;

        if had_ttl
            ttl_trial_positions(end+1) = numel(block_trial_log); %#ok<SAGROW>
        end

        ttl_count = double(TrialRecord.User.num_TTL);
        %disp(ttl_count)
        block_trial_log(end).ttl_count = ttl_count;


    end
    last_logged_trial_count = ntr_done;
end

% =================== POINTER UPDATE (based on previous trial) ===================
if ~isempty(TrialRecord.TrialErrors)
    if TrialRecord.TrialErrors(end) == 0
        cond_ptr = cond_ptr + 1;  % advance on success
    else
        % stay on same condition on non-zero error
    end
end

% =================== BLOCK WRAP ===================
if cond_ptr > N_COND
    % --- 1) Pull FR matrix for this block from server ---
    [FR, rows, cols] = pull_FR_matrix(fr_server_ip, fr_server_port);
    
    % ---- Align FR columns to TTLs using per-trial ttl_count ----
    % Build a 1D vector whose length is the total # of TTLs observed in the block.
    % Each entry is the trial error code for the TTL at that time.
    err_per_ttl       = [];   % e.g., [0 0 0 ... 3 3 3 ... 0 0 ...]
    cond_idx_per_ttl  = [];   % parallel vector telling which condition each TTL came from
    for k = 1:numel(block_trial_log)
        if block_trial_log(k).had_ttl
            n = double(block_trial_log(k).ttl_count);
            if n > 0
                err_per_ttl      = [err_per_ttl,      repmat(block_trial_log(k).err_code, 1, n)]; %#ok<AGROW>
                cond_idx_per_ttl = [cond_idx_per_ttl, repmat(block_trial_log(k).cond_idx, 1, n)]; %#ok<AGROW>
            end
        end
    end

    % Sanity checks (rows, columns)
    if rows ~= 32
        error('FR rows=%d (expected 32).', rows);
    end
    if numel(err_per_ttl) ~= cols
        error('Mismatch: FR cols=%d but per-TTL error vector has length %d.', cols, numel(err_per_ttl));
    end

    % Keep only TTLs from successful trials (error==0)
    keep_mask    = (err_per_ttl == 0);
    %disp('keep_mask')
    %disp(keep_mask)
    FR_ok        = FR(1:32, keep_mask);           % 32 x (#TTL from successful trials)
    cond_ok      = cond_idx_per_ttl(keep_mask);   % 1 x (#TTL from successful trials)

    % Expectation (complete block): 4 successful trials × 10 TTL each = 40 kept TTLs
    n_ok = size(FR_ok, 2);
    if n_ok ~= (IMGS_PER_BLOCK+NatIMGS_PER_BLOCK)
        error('Expected %d TTLs from successful trials, but got %d. Proceeding with available TTLs.', (IMGS_PER_BLOCK+NatIMGS_PER_BLOCK), n_ok);
    end

    % --- 3) Build 40-length score vector from the kept TTLs ---
    % We assume each successful trial for a condition yields exactly 10 TTLs,
    % in the order the 10 images were shown for that condition.
    %scores = nan(IMGS_PER_BLOCK, 1);

    % Which FR row to use
    fr_row = fr_chan + 1;
    % fr_row = max(1, min(32, fr_row)); % make sure it is in the boundry

   % For each condition 1..N_COND, find its TTLs (should be 10) in chronological order
    % for cond = 1:N_COND
    %     idx = find(cond_ok == cond);  % TTL indices belonging to this condition
    %     if isempty(idx)
    %         % no successful trial for this condition in this block; leave NaNs for now
    %         continue
    %     end
    %     % Use at most IMGS_PER_COND = 10 TTLs (in case of any extra)
    %     %take = idx(1:min(IMGS_PER_COND, numel(idx)));
    %     vals = FR_ok(fr_row, idx);
    % 
    %     % Fill the slots for this condition (positions are fixed: ((cond-1)*10 + 1 .. +10))
    %     lin = ((cond-1)*IMGS_PER_COND + (1:numel(idx)));
    %     scores(lin) = vals(:);
    %     disp(idx)
    % end
    scores = FR_ok(fr_row, :); % all scores, the first 40 are generated image, the last 20 are control images
    %scores_ctrl = FR_ok(fr_row, IMGS_PER_BLOCK+1:end); 

    % --- (AlexNet scoring kept for reference; disabled) ---
    % imgs = []; acts_fc6 = [];
    % if ~isempty(net)
    %     imgs = read_block_images(block_image_names, 227, 227); % helper could read/resize
    %     acts_fc6 = zeros(IMGS_PER_BLOCK, 4096, 'single');
    %     for i = 1:IMGS_PER_BLOCK
    %         a = activations(net, imgs(:,:,:,i), alex_layer);
    %         acts_fc6(i,:) = single(squeeze(a))';
    %     end
    %     scores = acts_fc6(:,alex_iChan) - acts_fc6(:,alex_iChan_inh);
    % end

    % --- 4) Log CURRENT block (codes/names/scores/generation) ---
    codes_for_log = codes_block;

    codes_all   = [codes_all;  codes_for_log];
    scores_all  = [scores_all; scores(:)];
    generations = [generations; ones((IMGS_PER_BLOCK+NatIMGS_PER_BLOCK),1)*current_block_idx];
    names_all   = [names_all;  block_image_names(:)];

    TrialRecord.User.scores_all = scores_all;
    TrialRecord.User.generations = generations;

    % --- 5) End experiment? ---
    if current_block_idx >= MAX_BLOCKS 

        t_socket = [];
        if isempty(t_socket) || ~isvalid(t_socket)
            t_socket = tcpclient(fr_server_ip, fr_server_port, "Timeout", 5);
            configureTerminator(t_socket, "LF");
            fprintf("Connected to %s:%d\n", fr_server_ip, fr_server_port);
        end
        % ask the server to end
        writeline(t_socket, "End_Task");

        % Save & finish (no next block generation)
        try, save(fullfile(OUT_DIR_REL,'codes_all.mat'),      'codes_all',      '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'scores_all.mat'),     'scores_all',     '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'generations.mat'),    'generations',    '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'img_traj.mat'),       'img_traj',       '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'names_all.mat'),      'names_all',      '-v7.3'); end

        try
            figure; montage(img_traj(~cellfun(@isempty,img_traj))); title('Block representatives');
            xlabel('Generation'); ylabel('activation');
        catch, end
        try
            figure; scatter(generations, scores_all); xlabel('Generation'); ylabel('FR score'); title('Scores by block');
        catch, end

        C = {sprintf('fix(%d,%d)', fix(1), fix(2))};   % graceful end
        TrialRecord.NextBlock = -1;  %#ok<NASGU>
        TrialRecord.NextCondition = 1; %#ok<NASGU>
        return
    end

    % --- 6) Evolve to NEXT block using the FR scores we just computed ---
    next_block_idx = current_block_idx + 1;

    scores = scores';
    %disp('------scores---------')
    %disp((scores)')
    % disp('-----codes_block ------')
    % disp(size(codes_block))
    
    [codes_new, ~, ~] = optim.doScoring(codes_block, scores(1:IMGS_PER_BLOCK), true);
    codes_block = codes_new;



    % --- 7) Render NEXT block images (or reuse if no generator) ---
    [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, next_block_idx, nat_names_block_in);
    

    % --- 8) Representative for NEXT block ---
    img_traj{next_block_idx} = block_repr_image(G, codes_block, block_image_names(1:IMGS_PER_BLOCK));

    % --- 9) Reset per-block bookkeeping & scheduling ---
    current_block_idx = next_block_idx;
    cond_order = 1:N_COND; %randperm(N_COND);
    cond_ptr   = 1;

    block_trial_log = struct('cond_idx', {}, 'err_code', {}, 'had_ttl', {});
    ttl_trial_positions = [];
    last_logged_trial_count = numel(TrialRecord.TrialErrors);  % synced up
    last_returned_cond_idx = [];  % will be set below when we output C
end

% =================== Pick current condition and return TaskObjects ===================
%cond_ptr = min(max(cond_ptr,1), N_COND);
cond_idx   = cond_order(cond_ptr);            % 1..4
names_cond = block_cond_names(cond_idx, :);   % 1×10 filenames

% TaskObjects: #1 is fixation, then the 10 images for this condition
C = { sprintf('fix(%d,%d)', fix(1), fix(2)) };
for k = 1:IMGS_PER_COND
    C{end+1} = sprintf('pic(%s,%f,%f,%f,%f)', names_cond{k}, img_loc(1), img_loc(2), img_size(1), img_size(2)); %#ok<AGROW>
    %disp(sprintf('%d: pic(%s)', k, names_cond{k}));
    % ... fixation (#1) + 10 pics (#2..#11)
    %C{end+1} = 'ttl(1)';   % <-- adds TTL on digital port 1 as TaskObject #12
end

% Remember which condition we scheduled THIS trial with (to log on next call)
last_returned_cond_idx = cond_idx;

% Informational (for UI)
TrialRecord.NextBlock     = current_block_idx;
TrialRecord.NextCondition = cond_idx;

% Update information regarding plotting function
TrialRecord.User.scores_all = scores_all;
TrialRecord.User.generations = generations;
TrialRecord.User.IMGS_PER_BLOCK =IMGS_PER_BLOCK;
TrialRecord.User.NatIMGS_PER_BLOCK =NatIMGS_PER_BLOCK;

end % ======= end of evoStimTCP_userloop =======





