function [C,timingfile,userdefined_trialholder] = evoStimTCP_userloop(MLConfig,TrialRecord)
% evoStimTCP_userloop
% - 4 conditions per block
% - 10 images per condition (shown by evoStimTCP.m timing file)
% - Block 1 can use images.mat::NAMES; later blocks can be generated from CODES via FC6Generator + CMA-ES.
% - Pointer moves only after a correct trial; on wrap, NEXT block is built immediately.
% - LOGGING POLICY: we log the block that was JUST SHOWN (scores/codes/names for current_block_idx).

% ---- outputs ----
C = [];
timingfile = 'evoStimTCP.m';
userdefined_trialholder = '';

% ---- MonkeyLogic calls userloop twice before Trial 1; return early the first time ----
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

% =================== Design constants ===================
IMGS_PER_BLOCK = 40;                 % total images per block
IMGS_PER_COND  = 10;                 % images per condition
N_COND         = IMGS_PER_BLOCK/IMGS_PER_COND;  % 4 conditions per block
MAX_BLOCKS     = 5;

% AlexNet scoring (used for evolution/logging)
alex_layer         = 'fc6';
alex_iChan         = 2;
alex_iChan_inh     = 3;

% =================== Persistent state ===================
persistent init_done
persistent G net optim
persistent codes_block                      % [40 x 4096] codes that PRODUCED the *current* block
persistent block_image_names                % [40 x 1] relative paths (for the *current* block)
persistent block_cond_names                 % [4 x 10]  table of current block image names
persistent cond_order cond_ptr              % randomized order and pointer within block (1..4)
persistent current_block_idx                % 1..MAX_BLOCKS
persistent use_names_firstblock             % true if the first block uses S.NAMES (file images)
persistent OUT_DIR OUT_DIR_REL              % output folder roots
persistent codes_all scores_all generations img_traj names_all

% =================== One-time init ===================
if isempty(init_done)
    % --- Create timestamped output folder ---
    stamp_folder = [datestr(now,'yymmdd_HHMMSS') '__evol_stimuli'];
    OUT_DIR = fullfile(pwd, stamp_folder);
    if ~exist(OUT_DIR,'dir'), mkdir(OUT_DIR); end
    OUT_DIR_REL = stamp_folder;

    % --- Load generator / model (optional if you only use NAMES) ---
    try
        G   = FC6Generator('matlabGANfc6.mat');   % ensure file on path if using evolution
    catch
        G = []; % allow file-based only
    end
    try
        net = alexnet();                          % for scoring if using evolution
    catch
        net = [];
    end

    % --- CMA-ES (population == IMGS_PER_BLOCK) ---
    if ~isempty(G)
        opts   = struct('init_sigma',3.0,'popsize',IMGS_PER_BLOCK);
        optim  = CMAES_simple(4096, [], opts);
    else
        optim = [];
    end

    % --- Seed codes / names (prefer images.mat) ---
    codes_block = [];
    use_names_firstblock = false;

    if exist(fullfile(pwd,'images.mat'),'file')
        S = load(fullfile(pwd,'images.mat'));
        % Use NAMES for block 1 if available (and copy to standard names under OUT_DIR)
        if isfield(S,'NAMES') && iscell(S.NAMES) && numel(S.NAMES) >= IMGS_PER_BLOCK
            idx_names      = 1:IMGS_PER_BLOCK;  % or randperm(...)
            names_block_in = S.NAMES(idx_names);
            [block_image_names, block_cond_names] = build_block_from_names(names_block_in, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1);
            use_names_firstblock = true;
        end
        % Keep CODES to enable evolution for next blocks, ideally aligned to NAMES
        if isfield(S,'CODES') && size(S.CODES,2)==4096
            if size(S.CODES,1) >= IMGS_PER_BLOCK
                codes_block = double(S.CODES(1:IMGS_PER_BLOCK,:));
            else
                idx = randi(size(S.CODES,1),[IMGS_PER_BLOCK 1]);
                codes_block = double(S.CODES(idx,:));
            end
        end
    end

    % If not using file names for block 1, generate from codes (if generator available)
    if ~use_names_firstblock
        if isempty(codes_block)
            rng('shuffle');
            codes_block = normrnd(0,0.8,[IMGS_PER_BLOCK,4096]);
        end
        if isempty(G)
            error('No NAMES for block 1 and no generator available. Provide images.mat::NAMES or put FC6Generator on path.');
        end
        [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, 1);
    end

    % --- Schedule & counters ---
    cond_order = randperm(N_COND);   % permutation of [1 2 3 4]
    cond_ptr   = 1;
    current_block_idx = 1;

    % --- Bookkeeping logs ---
    codes_all = [];
    scores_all = [];
    generations = [];
    img_traj = cell(MAX_BLOCKS,1);
    names_all = {};

    % --- img_traj for Block 1 (representative) ---
    img_traj{1} = build_block_repr_image(G, codes_block, block_image_names);

    init_done = true;
end

% =================== POINTER UPDATE (based on previous trial) ===================
% Advance pointer ONLY if the previous trial was correct.
if ~isempty(TrialRecord.TrialErrors)
    if TrialRecord.TrialErrors(end) == 0
        cond_ptr = cond_ptr + 1;  % move to next condition on success
    else
        % incorrect trial: keep cond_ptr unchanged to repeat same condition
    end
end

% =================== BLOCK WRAP (when we've just finished a block) ===================
if cond_ptr > N_COND
    % --- 1) Compute scores for the block that was just shown (current_block_idx) ---
    scores_cur = score_block_images(block_image_names, net, alex_layer, alex_iChan, alex_iChan_inh);

    % If we had no codes for this block (e.g., first block used NAMES only),
    % keep shapes consistent with NaNs.
    if isempty(codes_block)
        codes_for_log = nan(IMGS_PER_BLOCK, 4096);
    else
        codes_for_log = codes_block;
    end

    % --- Append logs for the JUST-FINISHED block ---
    codes_all   = [codes_all;  codes_for_log];
    scores_all  = [scores_all; scores_cur(:)];
    generations = [generations; ones(IMGS_PER_BLOCK,1)*current_block_idx];
    names_all   = [names_all;  block_image_names(:)];

    % End of experiment?
    if current_block_idx >= MAX_BLOCKS
        % --- Save everything and finish (do NOT create a new block) ---
        try, save(fullfile(OUT_DIR_REL,'codes_all.mat'),      'codes_all',      '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'scores_all.mat'),     'scores_all',     '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'generations.mat'),    'generations',    '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'img_traj.mat'),       'img_traj',       '-v7.3'); end
        try, save(fullfile(OUT_DIR_REL,'names_all.mat'),      'names_all',      '-v7.3'); end

        % Simple visualization
        try
            figure; montage(img_traj(~cellfun(@isempty,img_traj))); title('Block representatives'); 
            xlabel('Generation'); ylabel('activation');
        catch, end
        try
            figure; scatter(generations, scores_all); xlabel('Generation'); ylabel('activation'); title('Scores by block');
        catch, end

        % Graceful end
        C = {'fix(0,0)'};   % dummy to let ML end gracefully
        TrialRecord.NextBlock = -1;  %#ok<NASGU>
        TrialRecord.NextCondition = 1; %#ok<NASGU>
        return
    end

    % --- 2) Evolve codes using these scores to build the NEXT block ---
    next_block_idx = current_block_idx + 1;

    if ~isempty(G) && ~isempty(net) && ~isempty(optim) && ~isempty(codes_block)
        % Use current block's codes and scores to produce next codes
        [codes_new, ~, ~] = optim.doScoring(codes_block, scores_cur, true);
        codes_block = codes_new;
    else
        % If we cannot evolve (e.g., first block was names-only with no codes), seed random
        if isempty(G)
            warning('Generator unavailable; reusing last images for the next block.');
        else
            rng('shuffle');
            codes_block = normrnd(0,0.8,[IMGS_PER_BLOCK,4096]);
        end
    end

    % --- 3) Render & save NEXT block images (or reuse if no generator) ---
    if ~isempty(G)
        [block_image_names, block_cond_names] = build_block_images(G, codes_block, OUT_DIR, OUT_DIR_REL, N_COND, IMGS_PER_COND, next_block_idx);
    else
        % No generator: do not change images; block_image_names stays as is.
        % (Not recommended, but keeps the session running.)
        warning('No generator found; next block will reuse previous images.');
        % filenames remain the same, so no rebuild needed.
    end

    % --- 4) Representative image for NEXT block ---
    img_traj{next_block_idx} = build_block_repr_image(G, codes_block, block_image_names);

    % --- 5) Reset scheduling for next block ---
    current_block_idx = next_block_idx;
    cond_order = randperm(N_COND);
    cond_ptr   = 1;
end

% =================== Pick current condition and return TaskObjects ===================
% Final safety clamp (should not be needed, but avoids crashes)
cond_ptr = min(max(cond_ptr,1), N_COND);

cond_idx   = cond_order(cond_ptr);            % 1..4
names_cond = block_cond_names(cond_idx, :);   % 1×10 filenames (relative)

% TaskObjects: #1 is fixation, then the 10 images for this condition
C = { 'fix(0,0)' };
for k = 1:IMGS_PER_COND
    C{end+1} = sprintf('pic(%s,0,0)', names_cond{k}); %#ok<AGROW>
end

% Informational (for UI; ML ignores for scheduling when using userloop)
TrialRecord.NextBlock     = current_block_idx;
TrialRecord.NextCondition = cond_idx;

% IMPORTANT: Do NOT advance pointer here.
% Pointer will be advanced at the TOP of the next userloop call if the trial was correct.

end % ======= end of evoStimTCP_userloop =======






