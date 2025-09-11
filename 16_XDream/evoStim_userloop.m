function [C,timingfile,userdefined_trialholder] = evoStim_userloop(MLConfig,TrialRecord)
% evoStim_userloop: 4 conditions per block, each condition shows 10 images.
% Block 1:
%   - Uses file names stored in images.mat::NAMES (e.g., 'stim_images\img_001.png').
%   - Copies those images into a new timestamped folder like '250907_160331__evol_stimuli'.
% Later blocks:
%   - Images are GENERATED from IMGS_PER_BLOCK x 4096 latent codes (FC6 space) using G.visualize,
%     scored by AlexNet ('fc6'), evolved by CMA-ES, and saved into the SAME folder.

% ---- outputs ----
C = [];
timingfile = 'evoStim.m';            % timing script shows *all* pics after fix
userdefined_trialholder = '';

% ---- MonkeyLogic calls userloop twice before Trial 1; return early the first time ----
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

% =================== Design constants ===================
IMGS_PER_BLOCK = 40;
IMGS_PER_COND  = 10;                         % 10 images per condition
N_COND         = IMGS_PER_BLOCK/IMGS_PER_COND;  % = 4
MAX_BLOCKS     = 10;

% AlexNet scoring settings (placeholder; can be replaced by FR from recording system)
alex_layer     = 'fc6';
alex_iChan     = 2;
alex_iChan_inh     = 2;
alex_ix        = 1;  %#ok<NASGU>
alex_iy        = 1;  %#ok<NASGU>

% =================== Persistent state ===================
persistent init_done
persistent G net optim
persistent codes_block                      % IMGS_PER_BLOCK x 4096 double
persistent block_image_names                % IMGS_PER_BLOCK x 1 cellstr
persistent block_cond_names                 % N_COND x IMGS_PER_COND cellstr
persistent cond_order cond_ptr              % randomized order and pointer within block
persistent current_block_idx                % 1..MAX_BLOCKS
persistent last_trial_count_correct         % to detect end-of-block
persistent use_names_firstblock             % true if the first block uses S.NAMES
persistent OUT_DIR OUT_DIR_REL              % absolute and relative output folder roots
persistent codes_all
persistent scores_all
persistent generations
persistent img_traj

% =================== One-time init ===================
if isempty(init_done)
    % --- Create a timestamped output folder like '250907_160331__evol_stimuli' ---
    stamp_folder = [datestr(now,'yymmdd_HHMMSS') '__evol_stimuli'];  % e.g., 250907_160331__evol_stimuli
    OUT_DIR = fullfile(pwd, stamp_folder);
    if ~exist(OUT_DIR,'dir'), mkdir(OUT_DIR); end
    OUT_DIR_REL = stamp_folder;  % relative (for MonkeyLogic pic(...))

    % --- Load generator and model ---
    G   = FC6Generator('matlabGANfc6.mat');   % ensure file on path
    net = alexnet();                          % requires DL Toolbox / Support Package

    % --- CMA-ES (population == IMGS_PER_BLOCK) ---
    opts   = struct('init_sigma',3.0,'popsize',IMGS_PER_BLOCK);
    optim  = CMAES_simple(4096, [], opts);

    % --- Seed codes (from images.mat::CODES if available; otherwise random) ---
    codes_block = [];
    use_names_firstblock = false;

    % Prefer images.mat if present (to use NAMES for the FIRST block)
    if exist(fullfile(pwd,'images.mat'),'file')
        S = load(fullfile(pwd,'images.mat'));

        % If NAMES available (>= IMGS_PER_BLOCK), use them for the FIRST block (copy into OUT_DIR)
        if isfield(S,'NAMES') && iscell(S.NAMES) && numel(S.NAMES) >= IMGS_PER_BLOCK
            idx_names   = 1:IMGS_PER_BLOCK;            % take the first 40; change to randperm if desired
            names_block = S.NAMES(idx_names);
            [block_image_names, block_cond_names] = build_block_from_names(names_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1);
            use_names_firstblock = true;
        end

        % If CODES available (>= IMGS_PER_BLOCK x 4096), keep them to enable evolution for later blocks
        if isfield(S,'CODES') && size(S.CODES,2)==4096
            if size(S.CODES,1) >= IMGS_PER_BLOCK
                codes_block = double(S.CODES(1:IMGS_PER_BLOCK,:));
            else
                idx = randi(size(S.CODES,1),[IMGS_PER_BLOCK 1]);
                codes_block = double(S.CODES(idx,:));
            end
        end
    end

    % If we did NOT get first-block images from NAMES, build block 1 by GENERATING images from codes
    if ~use_names_firstblock
        if isempty(codes_block)
            rng('shuffle');
            codes_block = normrnd(0,0.8,[IMGS_PER_BLOCK,4096]);
        end
        [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1);
    end

    % --- Schedule & counters ---
    cond_order = randperm(N_COND);
    cond_ptr   = 1;
    current_block_idx        = 1;
    last_trial_count_correct = 0;
    codes_all = [];
    scores_all = [];
    generations = [];
    img_traj = {};

    init_done = true;
end

% =================== Condition scheduling ===================
% If last trial was correct (or first real trial), advance pointer.
% If error, repeat same condition (do not move pointer).
if isempty(TrialRecord.TrialErrors) || 0 == TrialRecord.TrialErrors(end)
    n_correct      = sum(TrialRecord.TrialErrors==0);
    block_corrects = n_correct - last_trial_count_correct;

    if cond_ptr > N_COND
        block_corrects = N_COND;  % safety cap
    end

    % If the just-completed block finished, build the next block (unless MAX_BLOCKS reached).
    if (block_corrects >= N_COND) || (cond_ptr > N_COND)
        if current_block_idx >= MAX_BLOCKS
            TrialRecord.NextBlock = -1;  % end task
            TrialRecord.NextCondition = 1;
            C = {'fix(0,0)'};  % dummy
            % Save all these variables:
            save(fullfile(OUT_DIR_REL,'codes_all.mat'),      'codes_all',      '-v7.3');
            save(fullfile(OUT_DIR_REL,'scores_all.mat'),     'scores_all',     '-v7.3');
            save(fullfile(OUT_DIR_REL,'generations.mat'),    'generations',    '-v7.3');
            save(fullfile(OUT_DIR_REL,'img_traj.mat'),       'img_traj',       '-v7.3');
            % Plot the evolution of the average of all images.
            figure;
            montage(img_traj)
            xlabel("Generation"); ylabel("activation")
            figure;
            scatter(generations, scores_all)
            xlabel("Generation"); ylabel("activation")
            return
        end

        % =================== Build NEXT block ===================
        next_block_idx = current_block_idx + 1;

        if use_names_firstblock
            % Block 1 was file-based; now start generating from codes.
            if isempty(codes_block)
                rng('shuffle');
                codes_block = normrnd(0,0.8,[IMGS_PER_BLOCK,4096]);
            end
            [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, next_block_idx);
            use_names_firstblock = false;
        else
            % Normal evolutionary path: score current codes, update, then render next block.
            imgs = G.visualize(codes_block');  % -> HxWx3xIMGS_PER_BLOCK uint8

            % Ensure AlexNet input size (227x227); resize per image for robustness
            if size(imgs,1) ~= 227 || size(imgs,2) ~= 227
                imtmp = zeros(227,227,3,IMGS_PER_BLOCK,'uint8');
                for i = 1:IMGS_PER_BLOCK
                    imtmp(:,:,:,i) = imresize(imgs(:,:,:,i), [227 227]);
                end
                imgs = imtmp; clear imtmp
            end

            % Score with AlexNet (per-image to avoid API batch quirks)
            acts_fc6 = zeros(IMGS_PER_BLOCK, 4096, 'single');
            for i = 1:IMGS_PER_BLOCK
                a = activations(net, imgs(:,:,:,i), alex_layer);
                a = squeeze(a);                % 4096x1
                acts_fc6(i,:) = single(a(:))'; % 1x4096
            end
            %scores = acts_fc6(:, alex_iChan);   % IMGS_PER_BLOCK x 1
            
            scores = acts_fc6(:, alex_iChan)-acts_fc6(:, alex_iChan_inh);

            % CMA-ES update
            [codes_new, ~, ~] = optim.doScoring(codes_block, scores, true);
            % record some info for analysis
            codes_all = [codes_all; codes_new];
            scores_all = [scores_all; scores];
            generations = [generations; ones(numel(scores),1)*(next_block_idx-1)];
            img_traj{(next_block_idx-1)} = G.visualize(mean(codes_block,1));

            codes_block = codes_new;

            % Render next block into the same OUT_DIR
            [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, next_block_idx);
        end

        % Reset for next block
        current_block_idx = next_block_idx;
        cond_order = randperm(N_COND);
        cond_ptr   = 1;
        last_trial_count_correct = n_correct;
    end
end

% =================== Pick current condition and return TaskObjects ===================
cond_idx  = cond_order(cond_ptr);
names_cond = block_cond_names(cond_idx, :);   % 1×IMGS_PER_COND filenames

% TaskObjects: #1 is fixation, then IMGS_PER_COND images
C = { 'fix(0,0)' };
for k = 1:IMGS_PER_COND
    C{end+1} = sprintf('pic(%s,0,0)', names_cond{k}); %#ok<AGROW>
end

% Informational only (ML ignores for scheduling when using userloop)
TrialRecord.NextBlock     = current_block_idx;
TrialRecord.NextCondition = cond_idx;

% Advance pointer now; if the upcoming trial errors, we won’t advance next time
if isempty(TrialRecord.TrialErrors) || 0 == TrialRecord.TrialErrors(end)
    cond_ptr = cond_ptr + 1;
end

end % --------- end of userloop ---------






