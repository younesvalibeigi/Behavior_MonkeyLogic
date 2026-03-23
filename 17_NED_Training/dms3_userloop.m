function [C,timingfile,userdefined_trialholder] = dms3_userloop(MLConfig,TrialRecord)

C = [];
timingfile = 'dms3.m';
userdefined_trialholder = '';

% The very first call to this userloop function is made before a task
% starts and it is for retrieving the name(s) of the timing file(s).
% We will return without determining the trial condition for the first call.
persistent FirstCall
if isempty(FirstCall), FirstCall = true; return, end


%img_dir = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_Ned_training_1\natural_images';
img_dir = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_NED_Training\natural_images';

% choose A/B ONCE per session
persistent img1 img2 empty img3 img4 initialized
if isempty(initialized), initialized = false; end

if ~initialized
    idx = randperm(800,2);
    idx = [372 665];
    img1 = fullfile(img_dir, sprintf('nat_%03d.png', idx(1)));
    img2 = fullfile(img_dir, sprintf('nat_%03d.png', idx(2)));
    empty = fullfile(img_dir, 'empty.png');
    %img3 = fullfile(img_dir, sprintf('nat_%03d.png', idx(3)));
    %img4 = fullfile(img_dir, sprintf('nat_%03d.png', idx(4)));
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

% The code below selects a condition randomly without replacement and
% repeats error trials immediately.

% TrialRecord.CurrentTrialNumber of the n-th trial is (n-1) in the userloop.
persistent cond
if 0==TrialRecord.CurrentTrialNumber  % run only once
    % Conditions = { cond_num, sample, match, match_position, nonmatch, nonmatch_position }
    % Conditions = {cond_num, frequency, block_num, fix, sample, sample_pos,
    % sample_size, target, target_pos, target_size, distractor, distractor_pos, distractor_size}
    first_cond = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, img2, [spos 0],  ch_size};
    Conditions = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, img2, [spos 0],  ch_size; 
                    2, 1, 1, fix, img1, sample_pos, sample_size, img1, [spos 0], ch_size,  img2, [-spos 0],  ch_size;
                    3, 1, 1, fix, img2, sample_pos, sample_size, img2, [-spos 0], ch_size,  img1, [spos 0],  ch_size;
                    4, 1, 1, fix, img2, sample_pos, sample_size, img2, [spos 0], ch_size,  img1, [-spos 0],  ch_size;
                    };
    Conditions_singleChoice = {  1, 1, 1, fix, img1, sample_pos, sample_size, img1, [-spos 0], ch_size, empty, [spos 0],  ch_size; 
                    2, 1, 1, fix, img1, sample_pos, sample_size, img1, [spos 0], ch_size,  empty, [-spos 0],  ch_size;
                    3, 1, 1, fix, img2, sample_pos, sample_size, img2, [-spos 0], ch_size,  empty, [spos 0],  ch_size;
                    4, 1, 1, fix, img2, sample_pos, sample_size, img2, [spos 0], ch_size,  empty, [-spos 0],  ch_size;
                    };
    
 
    %cond = Conditions;
    cond = Conditions_singleChoice;
end

% when all the conditions are used, end the task.
if isempty(cond)
    TrialRecord.NextBlock = -1;
    return
end
% Assign a new condition if the last trial was a success.
if isempty(TrialRecord.TrialErrors)
    TrialRecord.NextBlock = first_cond{1, 3}; % block number
    TrialRecord.NextCondition = first_cond{1,1};  % condition number
    TrialRecord.User.cond = first_cond(1,1:end);
elseif 0==TrialRecord.TrialErrors(end) || 5==TrialRecord.TrialErrors(end) || 9==TrialRecord.TrialErrors(end) % TrialRecord.TrialErrors is empty at the beginning.
    % Userloop does not need the block and condition numbers. This is just
    % for your record keeping.
%     TrialRecord.NextBlock = cond{1,1};      % block number
%     TrialRecord.NextCondition = cond{1,2};  % condition number
%     TrialRecord.User.cond = cond(1,3:end);
%     cond(1,:) = [];                         % remove the used condition

    % Randomly pick a condition
    %idx_cond = randi(num_cond);
    freq = cell2mat(cond(:,2));   % extract frequency column
    prob = freq / sum(freq);      % normalize to probabilities
    idx_cond = find(rand <= cumsum(prob), 1, 'first');
    TrialRecord.NextBlock = cond{idx_cond, 3}; % block number
    TrialRecord.NextCondition = cond{idx_cond,1};  % condition number
    TrialRecord.User.cond = cond(idx_cond,1:end);
    
    
end

