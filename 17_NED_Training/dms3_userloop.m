function [C,timingfile,userdefined_trialholder] = dms3_userloop(MLConfig,TrialRecord)

C = [];
timingfile = 'dms3.m';
userdefined_trialholder = '';

persistent num_contrast_levels
num_contrast_levels = 200;

% Pick the folder where your images are saved: <<<<<<<<<<<<<<<<<<<<<<<
%img_dir = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_Ned_training_1\natural_images';
img_dir = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_NED_Training\natural_images';
progressive_img_dir = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_NED_Training\progressive_images';


% The very first call to this userloop function is made before a task
% starts and it is for retrieving the name(s) of the timing file(s).
% We will return without determining the trial condition for the first call.
persistent FirstCall
if isempty(FirstCall), FirstCall = true; return, end


% choose A/B ONCE per session
persistent img1 img2 empty img3 img4 initialized 
persistent prog_img1 prog_img2 prog_level
if isempty(initialized), initialized = false; end

if ~initialized
    idx = randperm(800,2);
    idx = [26 449];%[164 179];%[372 665];
    img1 = fullfile(img_dir, sprintf('nat_%03d.png', idx(1)));
    img2 = fullfile(img_dir, sprintf('nat_%03d.png', idx(2)));
    empty = fullfile(img_dir, 'empty.png');
    %img3 = fullfile(img_dir, sprintf('nat_%03d.png', idx(3)));
    %img4 = fullfile(img_dir, sprintf('nat_%03d.png', idx(4)));

    % Make 100 progressive distractor images:
    % level 1   = empty
    % level 100 = full image
    
    if ~exist(progressive_img_dir, 'dir')
        mkdir(progressive_img_dir);
    end
    delete(fullfile(progressive_img_dir, '*'));
    % Make num_contrast_levels progressive distractor images and overwrite old ones
    prog_img1 = make_progressive_images(img1, empty, num_contrast_levels, fullfile(progressive_img_dir, 'img1'));
    prog_img2 = make_progressive_images(img2, empty, num_contrast_levels, fullfile(progressive_img_dir, 'img2'));

    % Start all 4 base conditions at level 1
    prog_level = ones(1,4);
    
    % End initialization
    TrialRecord.User.initalCond = true;
    initialized = true;
else
    TrialRecord.User.initalCond = false;
end

fix = [0 0];
sample_pos = [-3 -3];
pxperdeg = 36.039;
sample_size = [6 6]*pxperdeg;
spos = 10; % Saccade position
ch_size = [6 6]*pxperdeg;

% The code below selects a condition randomly according to the trial
% frequencies
% repeats error trials immediately.

% TrialRecord.CurrentTrialNumber of the n-th trial is (n-1) in the userloop.
%persistent cond
persistent cond_single cond_double cond_progressive
if 0==TrialRecord.CurrentTrialNumber  % run only once
    % Conditions = {cond_num, frequency, block_num, fix, sample, sample_pos,
    % sample_size, target, target_pos, target_size, distractor, distractor_pos, distractor_size}
    first_cond = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, img2, [spos 0],  ch_size};

    Conditions_doubleChoice = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, img2, [spos 0],  ch_size; 
                    2, 1, 1, fix, img1, sample_pos, sample_size, img1, [spos 0], ch_size,  img2, [-spos 0],  ch_size;
                    3, 1, 1, fix, img2, sample_pos, sample_size, img2, [-spos 0], ch_size,  img1, [spos 0],  ch_size;
                    4, 1, 1, fix, img2, sample_pos, sample_size, img2, [spos 0], ch_size,  img1, [-spos 0],  ch_size;
                    };
    Conditions_singleChoice = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, empty, [spos 0],  ch_size; 
                    2, 1, 1, fix, img1, sample_pos, sample_size, img1, [spos 0], ch_size,  empty, [-spos 0],  ch_size;
                    3, 1, 1, fix, img2, sample_pos, sample_size, img2, [-spos 0], ch_size,  empty, [spos 0],  ch_size;
                    4, 1, 1, fix, img2, sample_pos, sample_size, img2, [spos 0], ch_size,  empty, [-spos 0],  ch_size;
                    };
    
 
    % Here pick the right set of condition for your task
    %cond = Conditions_singleChoice; % Conditions_doubleChoice % <<<<<<<<<<<<<<<<<<<<<<<<<<<
    cond_single = Conditions_singleChoice;
    cond_double = Conditions_doubleChoice;
end

% when all the conditions are used, end the task.
if isempty(cond_single)
    TrialRecord.NextBlock = -1;
    return
end
% The first trial: Familiarization:
if isempty(TrialRecord.TrialErrors)
    TrialRecord.NextBlock = first_cond{1, 3}; % block number
    TrialRecord.NextCondition = first_cond{1,1};  % condition number
    TrialRecord.User.cond = first_cond(1,1:end);

% From the second trial the DMS task starts
elseif 0==TrialRecord.TrialErrors(end) || 5==TrialRecord.TrialErrors(end) || 9==TrialRecord.TrialErrors(end) % TrialRecord.TrialErrors is empty at the beginning.
    % Userloop does not need the block and condition numbers. This is just
    % for your record keeping.
%     TrialRecord.NextBlock = cond{1,1};      % block number
%     TrialRecord.NextCondition = cond{1,2};  % condition number
%     TrialRecord.User.cond = cond(1,3:end);
%     cond(1,:) = [];                         % remove the used condition

    

    

    % Choose which regime to use, single vs double choice
    choice_type = TrialRecord.Editable.single_vs_double_choice;
    if strcmp(choice_type, 'Single')
        cond = cond_single;
    elseif strcmp(choice_type, 'Double')
        cond = cond_double;
    end
    
    % Defining which algorithm for bias correction
    bias_correction_type = TrialRecord.Editable.bias_correction;
    if strcmp(bias_correction_type, 'None') % show each condition randomly
    
        % Randomly pick a condition
        %idx_cond = randi(num_cond);
        % older code: use fixed frequencies
        %freq = cell2mat(cond(:,2));   % extract frequency column
        % New code: use editable frequencies
        freq = [TrialRecord.Editable.freq_morph0 TrialRecord.Editable.freq_morph1 TrialRecord.Editable.freq_morph2 TrialRecord.Editable.freq_morph3 TrialRecord.Editable.freq_morph4];
        % Only keep the freq for defined conditions
        freq = freq(1:size(cond,1));
    
        prob = freq / sum(freq);      % normalize to probabilities
        idx_cond = find(rand <= cumsum(prob), 1, 'first');

        TrialRecord.NextBlock = cond{idx_cond, 3}; % block number
        TrialRecord.NextCondition = cond{idx_cond,1};  % condition number
        TrialRecord.User.cond = cond(idx_cond,1:end);
        
    elseif strcmp(bias_correction_type, 'AdaptiveBiasCorrection')
        % Adaptive bias-correction sampling
        window_n = 32; % on average 8 sample per condition
        idx_cond = pick_condition_adaptive_bias(cond, TrialRecord, window_n);

        TrialRecord.NextBlock = cond{idx_cond, 3}; % block number
        TrialRecord.NextCondition = cond{idx_cond,1};  % condition number
        TrialRecord.User.cond = cond(idx_cond,1:end);

    elseif strcmp(bias_correction_type, 'ProgressiveDistractorContrast')


        % Last trial outcome
        conditions = TrialRecord.ConditionsPlayed;
        errors     = TrialRecord.TrialErrors;
        valid_idx = find((errors == 0 | errors == 5 | errors == 9) & conditions >= 1 & conditions <= 4);
        conditions = conditions(valid_idx);
        errors = errors(valid_idx);


        % If last trial was not familiarization, update the previous condition level
        if errors(end) == 9
            cond_progressive = cond_single;
        elseif errors(end) == 0
            last_cond = conditions(end);
            % Make sure you did not reach the last level
            if prog_level(last_cond) <  num_contrast_levels
                % Update the level for the last condition
                prog_level(last_cond) = prog_level(last_cond) + 1;
                
                % Update the distractor for the last condition
                if last_cond == 1 || last_cond == 2
                   cond_progressive{last_cond, 11} =  prog_img2{prog_level(last_cond)};
                elseif last_cond == 3 || last_cond ==4
                    cond_progressive{last_cond, 11} =  prog_img1{prog_level(last_cond)};
                end
            end
        end
        
        % Check which conditinos are updated
        disp(['contrast levels: ' num2str(prog_level(1)) ', ' num2str(prog_level(2)) ', ' num2str(prog_level(3)) ', ' num2str(prog_level(4))])

        % Randomly choose one conditions
        % freq = [1 1 1 1];

        % Give higher probability to conditions with lower progress level
        freq = max(prog_level) - prog_level + 1;
        % If one condition has a lower prog_level, it means the monkey is doing worse on it.
        % max(prog_level) - prog_level + 1 gives that weaker condition a higher weight.
        % So weaker conditions are shown more often, and stronger ones less often.
        % This helps all four conditions progress more evenly.
    
        prob = freq / sum(freq);      % normalize to probabilities
        idx_cond = find(rand <= cumsum(prob), 1, 'first');

        TrialRecord.NextBlock = cond_progressive{idx_cond, 3}; % block number
        TrialRecord.NextCondition = cond_progressive{idx_cond,1};  % condition number
        TrialRecord.User.cond = cond_progressive(idx_cond,1:end);
    end

end
end


function idx_cond = pick_condition_adaptive_bias(cond, TrialRecord, window_n)
% Adaptive bias-correcting condition sampler for 4 conditions:
% 1 = A-left
% 2 = A-right
% 3 = B-left
% 4 = B-right
%
% Uses only trial errors 0 and 5 to compute performance.
% Reweights conditions to correct:
%   - side bias (left vs right)
%   - stimulus bias (A vs B)
%   - weak individual conditions
%
% Falls back gracefully when there is little data.

    num_cond = size(cond,1);

    % If not exactly 4 conditions, apply this to all morph levels
    % ================================ %
    % ====== Codes need to develp ==== %
    % ================================ %

    conditions = TrialRecord.ConditionsPlayed;
    errors     = TrialRecord.TrialErrors;

    % ------------------------------------------------------------
    % Settings
    % ------------------------------------------------------------
    %window_n   = 40;   % use last 40 valid (0/5) trials
    alpha_side = 0.8;  % strength of side-bias correction [0, 1] 0: no correction, 1: full correction
    alpha_stim = 0.8;  % strength of stimulus-bias correction
    alpha_ind  = 0.4;  % mild boost for weak individual conditions
    prob_floor = 0.10; % minimum probability per condition

    % ------------------------------------------------------------
    % Keep only valid trials for performance estimation
    % ------------------------------------------------------------
    valid_idx = find((errors == 0 | errors == 5) & conditions >= 1 & conditions <= 4);

    if isempty(valid_idx)
        % No history yet -> equal probability
        prob = ones(1,4) / 4;
        idx_cond = find(rand <= cumsum(prob), 1, 'first');
        return
    end

    % Use recent valid trials only
    valid_idx = valid_idx(max(1, end-window_n+1):end);

    cond_hist = conditions(valid_idx);
    err_hist  = errors(valid_idx);

    % ------------------------------------------------------------
    % Per-condition performance with Laplace smoothing
    % perf(c) = (correct + 1) / (correct + wrong + 2)
    % so early estimates are stable and never NaN
    % ------------------------------------------------------------
    perf = zeros(1,4);

    for c = 1:4
        n_correct = sum(cond_hist == c & err_hist == 0);
        n_wrong   = sum(cond_hist == c & err_hist == 5);
        perf(c)   = (n_correct + 1) / (n_correct + n_wrong + 2);
    end

    % ------------------------------------------------------------
    % Marginal performance
    % 1=A-left, 2=A-right, 3=B-left, 4=B-right
    % ------------------------------------------------------------
    side_perf = [mean([perf(1), perf(3)]), ... % left
                 mean([perf(2), perf(4)])];    % right

    stim_perf = [mean([perf(1), perf(2)]), ... % A
                 mean([perf(3), perf(4)])];    % B

    % Weakness = 1 - performance
    side_need = 1 - side_perf;
    stim_need = 1 - stim_perf;
    ind_need  = 1 - perf;

    % Normalize needs around 1
    side_factor = side_need / mean(side_need);
    stim_factor = stim_need / mean(stim_need);
    ind_factor  = ind_need  / mean(ind_need);

    % Shrink toward 1 so correction is gradual
    % Avoid sudden big changes in condition frequencies, this creates gradual changes
    side_factor = 1 + alpha_side * (side_factor - 1);
    stim_factor = 1 + alpha_stim * (stim_factor - 1);
    ind_factor  = 1 + alpha_ind  * (ind_factor  - 1);

    % ------------------------------------------------------------
    % Build weights from side x stimulus x individual weakness
    % ------------------------------------------------------------
    % cond1 = A-left
    % cond2 = A-right
    % cond3 = B-left
    % cond4 = B-right
    w = zeros(1,4);
    w(1) = stim_factor(1) * side_factor(1) * ind_factor(1);
    w(2) = stim_factor(1) * side_factor(2) * ind_factor(2);
    w(3) = stim_factor(2) * side_factor(1) * ind_factor(3);
    w(4) = stim_factor(2) * side_factor(2) * ind_factor(4);

    % Safety
    if any(~isfinite(w)) || all(w <= 0)
        w = ones(1,4);
    end

    % Normalize
    prob = w / sum(w);

    % Apply probability floor and renormalize
    prob = apply_probability_floor(prob, prob_floor);

    disp (['Update prob: ' num2str(prob(1)) ', ' num2str(prob(2)) ', ' num2str(prob(3)) ', ' num2str(prob(4))])

    % Sample condition
    idx_cond = find(rand <= cumsum(prob), 1, 'first');

    if isempty(idx_cond)
        idx_cond = randi(4);
    end
end


function prob = apply_probability_floor(prob, floor_val)
% Enforces a minimum probability for each entry and renormalizes.

    n = numel(prob);

    % If floor is impossible, fall back to uniform
    if floor_val * n >= 1
        prob = ones(1,n) / n;
        return
    end

    prob = prob(:)' / sum(prob);

    low = prob < floor_val;
    if ~any(low)
        return
    end

    deficit = sum(floor_val - prob(low));
    prob(low) = floor_val;

    high = ~low;
    high_sum = sum(prob(high));

    if high_sum <= 0
        prob = ones(1,n) / n;
        return
    end

    prob(high) = prob(high) - deficit * (prob(high) / high_sum);

    % Numerical safety
    prob(prob < 0) = 0;
    prob = prob / sum(prob);
end


function out_files = make_progressive_images(full_img_path, empty_img_path, n_levels, out_prefix)
% Make n_levels images going from empty to full image.
% Files are overwritten every session.

    img_full  = im2double(imread(full_img_path));
    img_empty = im2double(imread(empty_img_path));

    % Match size if needed
    if size(img_empty,1) ~= size(img_full,1) || size(img_empty,2) ~= size(img_full,2)
        img_empty = imresize(img_empty, [size(img_full,1), size(img_full,2)]);
    end

    % Match channels if needed
    if size(img_empty,3) ~= size(img_full,3)
        if size(img_empty,3) == 1 && size(img_full,3) == 3
            img_empty = repmat(img_empty, [1 1 3]);
        elseif size(img_full,3) == 1 && size(img_empty,3) == 3
            img_full = repmat(img_full, [1 1 3]);
        end
    end

    out_files = cell(1,n_levels);

    for k = 1:n_levels
        alpha = (k-1) / (n_levels-1);   % 0 = empty, 1 = full
        img_k = (1-alpha) * img_empty + alpha * img_full;

        out_files{k} = sprintf('%s_%03d.png', out_prefix, k);
        imwrite(img_k, out_files{k});   % overwrite old file
    end
end
