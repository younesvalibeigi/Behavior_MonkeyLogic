hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample_control',21,'Sample_microstimulation1',22,'Sample_microstimulation2',...
    30,'Delay',40,'Go',50,'Reward');  % behavioral codes

mouse_.showcursor(false);          % hide the mouse cursor from the subject; true, by default


fix_eventmaker = 10;
%sample_eventmaker = 20-control, 21-microstim1, 22-microstim2 
delay_eventmaker = 30;
go_eventmaker = 40;
reward_eventmaker = 50;

% detect an available tracker
if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

% define time intervals (in ms):
learn_time = 10000; % 10000
wait_for_fix = 20000; %5000;
initial_fix = 500;
sample_time = 1000;
delay = randi([250, 500]); %700; % random 200-500 ms --> saccade delay (monkey should  not predict time), super saccade
max_reaction_time = 3000;
hold_target_time = 50; %500; % for arya is 800

% fixation window (in degrees):
fix_radius = 1.9;
hold_radius = 2.5;
choice_radius = 3;

reward_duration = 180;
reward_interval = 100;
numbers_drops = [0, 1, 2, 3, 4];
probabilities_drops = [0.00, 0.10, 0.00, 0.00 0.00];
reward_dur_afterDelay = 0; % if 0, no reward after delay, if 


wrongChoice_delay = 100; %1100;
fixBreak_delay = 20;

% retrive frequencies
freq_morph0 = [1 1 1 1]; % 1st and 2nd are Most Exciting images, 3rd and 4th are Least Exciting images
freq_morph1 = [1 1 1 1]; % First morph levels
freq_morph2 = [1 1 1 1]; % Second morph levels
freq_morph3 = [1 1 1 1]; % third morph levels
freq_morph4 = [1 1 1 1]; % Last morph levels

single_vs_double_choice = 'Single'; % 'Double' % This line is for training phase
% In signle, only one choice is shown to the monkey, so monkey only need to
% saccade, in Double, two choices is given to the monkey


editable('fix_radius', 'hold_radius', ...
    'sample_time', 'hold_target_time', ...
    'reward_duration', 'reward_interval', 'probabilities_drops', 'reward_dur_afterDelay', ...
    'wrongChoice_delay', 'fixBreak_delay', ...
    'freq_morph0', 'freq_morph1', 'freq_morph2', 'freq_morph3', 'freq_morph4', ...
    'single_vs_double_choice');
bhv_variable('fix_radius', fix_radius, ...
    'hold_radius', hold_radius, ...
    'sample_time', sample_time, ...
    'delay_time', delay, ...
    'hold_target_time', hold_target_time, ...
    'reward_duration', reward_duration, ...
    'reward_interval', reward_interval, ...
    'probabilities_drops', probabilities_drops, ...
    'wrongChoice_delay', wrongChoice_delay, ...
    'fixBreak_delay', fixBreak_delay);


% Information regarding number of sets, levels, and conditions
num_levels = 7;
num_sets = 1+2; % 1 Control + 2 Microstim
num_conditions_perSet = num_levels*4;

% This example does not use TaskObjects and creates stimuli with adapters.
cond = TrialRecord.User.cond;
% Conditions = {1:cond_num, 2:frequency, 3:block_num, 4:fix, 5:sample, 6:sample_pos,
    % 7:sample_size, 8:target, 9:target_pos, 10:target_size, 11:distractor, 12:distractor_pos, 13:distractor_size}
if strcmp(MLConfig.FixationPointShape,'Square')
    fixation_point = BoxGraphic(null_);
    fix_size = MLConfig.FixationPointDeg;
else
    fixation_point = CircleGraphic(null_);
    fix_size = MLConfig.FixationPointDeg * 2;  % radius to diameter
end
fix_color = MLConfig.FixationPointColor;
fixation_point.List = { fix_color, fix_color, fix_size, cond{4} };  % { edge_color, face_color, size, position }
sample = ImageGraphic(null_);
sample.List = { cond{5}, cond{6}, cond{7} };  % sample: { image_file, position, size }
targets_distractor = ImageGraphic(null_);
targets_distractor.List = { cond{8}, cond{9}, cond{10};  % The 1st image is the target.
    cond{11}, cond{12}, cond{13} };             % The 2nd one is the distractor.




% familiarization: show BOTH choice images for learn_time (same positions)
learn_targets = ImageGraphic(null_);
learn_targets.List = { cond{8}, [-6 0], cond{10};  % The 1st image is the target.
    cond{11}, [6 0], cond{13} };             % The 2nd one is the distractor.

% scene 0: familiarization (time only)
tc0 = TimeCounter(null_);
tc0.Duration = learn_time;
con0 = Concurrent(tc0);
con0.add(learn_targets);
scene0 = create_scene(con0);


% scene 1: fixation
fix1 = SingleTarget(tracker);
fix1.Target = fixation_point;  % fixation_point will be turned on and off by SingleTarget
fix1.Threshold = fix_radius;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = wait_for_fix;
wth1.HoldTime = initial_fix;
scene1 = create_scene(wth1);

% scene 2: sample
% Generating ttl signal
if TrialRecord.CurrentCondition < 1*num_conditions_perSet +1 % Control
    ttl = TTLOutput(tracker);
    ttl.Port = 3;
    ttl.Duration = 10;
    sample_eventmaker = 20;
    %ttl.Delay = [ttl_delay 0];
    %wth2 = WaitThenHold(fix2);
    
else 
    if TrialRecord.CurrentCondition < 2*num_conditions_perSet+1 % micrsotim 1
        ttl_delay = delay_microstim1;
        sample_eventmaker = 21;
        ttl_port = 1;
    elseif TrialRecord.CurrentCondition < 3*num_conditions_perSet+1 % microstim 2
        ttl_delay = delay_microstim2;
        sample_eventmaker = 22;
        ttl_port = 2;
    end
    % add the ttl 3 signal with the microstim signal
    ttl = TTLOutput(tracker);
    ttl.Port = [ttl_port 3];
    ttl.Duration = [10 10];
    ttl.Delay = [ttl_delay 0];
end
fix2 = SingleTarget(ttl);
fix2.Target = fixation_point;
fix2.Threshold = fix_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = sample_time;
con2 = Concurrent(wth2);
con2.add(sample);
scene2 = create_scene(con2);

% scene 3: delay
fix3 = SingleTarget(tracker);
fix3.Target = fixation_point;
fix3.Threshold = hold_radius;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = delay;
scene3 = create_scene(wth3);

% scene 4: choice
mul4 = MultiTarget(tracker);
mul4.Target = targets_distractor;
mul4.Threshold = choice_radius;%fix_radius;
mul4.WaitTime = max_reaction_time;
mul4.HoldTime = hold_target_time;
mul4.TurnOffUnchosen = true;        % Determine whether to turn off the unchosen targets when one of the targets is chosen.
scene4 = create_scene(mul4);

% Familiarization ONCE per run (robust)
fam_done = TrialRecord.User.initalCond;

if TrialRecord.User.initalCond
    fprintf('Familiarization --------\n');
    run_scene(scene0, 5);
    fam_done = true;
    error_type = 9;
else
    %fprintf('Trial %d | Condition %d --------\n', TrialRecord.CurrentTrialNumber, cond{1});


    % DMS TASK:
    % errors: 
    % 0: complete and choosing target
    % 1: no fixation
    % 2: fixation aquired but not held (no sample shown)
    % 3: not maintaining fixation on the sample
    % 4: break fixation during the delay
    % 5: choosing the distractor
    % 6: choosing neither the distractor nor the target
    % 7: breaking the fixation on target or distractor
    error_type = 0;
    
    run_scene(scene1,fix_eventmaker); % Run the first scene (eventmaker 10)
    if ~wth1.Success      % If the WithThenHold failed (either fixation is not acquired or broken during hold), check whether we were waiting for fixation.
        if wth1.Waiting
            error_type = 1;%4; % If so, fixation was never made and therefore this is a "no fixation (1)" error.
        else
            error_type = 2;%3;    % If we were not waiting, it means that fixation was acquired but not held,
        end
    end
    
    if 0==error_type
        run_scene(scene2,sample_eventmaker);   % Run the second scene (eventmarker Control:20, microstim1:21, microstim2:22, microstim3:23)
        if ~wth2.Success   % The failure of WithThenHold indicates that the subject didn't maintain fixation on the sample image.
            error_type = 3;    % So it is a "break fixation (3)" error.
        end
    end
    
    if 0==error_type
        run_scene(scene3,delay_eventmaker);    % Run the third (delay) scene (eventmarker 30)
        if ~wth3.Success
            error_type = 4;%3; % break fixation (4)
        end
    end
    
    if 0==error_type
        if reward_dur_afterDelay > 0 %strcmp(reward_afterDelay, 'True')
            goodmonkey(reward_dur_afterDelay, 'juiceline',1, 'numreward',1, 'pausetime',reward_interval, 'eventmarker',reward_eventmaker, 'nonblocking', 2);
        end
        t_target = run_scene(scene4,go_eventmaker); % Run the fourth scene (eventmarker 40)
        if mul4.Success
            rt = mul4.RT;                % Assign rt for the reaction time graph. The same as rt = mul4.AcquiredTime - t_target;
            if 1~=mul4.ChosenTarget  % Image 1 is target; Image 2 is distractor.
                error_type = 5;      % One of the images was selected, but it was an incorrect choice.
            end
        else                       % The failure of MultiTarget means that none of the targets was chosen.
            if mul4.Waiting         % If we were waiting for the target selection (in other words, the gaze did not 
                error_type = 6;%2;     % land on either the target or distractor), it is a "late response (6)" error.
            else
                error_type = 7;%3;   % Otherwise, the fixation is broken (7) and the choice was not held to the end.
            end
        end
    end
    
    % reward
    if 0==error_type
        idle(0);
        %goodmonkey(reward_duration, 'juiceline',1, 'numreward',1, 'pausetime',200, 'eventmarker',reward_eventmaker);
        % give juice with random number of drops.
        % Define the numbers and their corresponding probabilities
        %numbers = [0, 1, 2, 3, 4];
        %probabilities = [0.05, 0.75, 0.15, 0.04 0.01];
        % Sample a number based on the specified probabilities
        % Sample a number based on the specified probabilities_drops
        num_juice = randsample(numbers_drops, 1, true, probabilities_drops);
        goodmonkey(reward_duration, 'juiceline',1, 'numreward',num_juice, 'pausetime',reward_interval, 'eventmarker',reward_eventmaker, 'nonblocking', 2);
                                                                                
    elseif 5 == error_type % choosing the distractor    || 6 == error_type || 7 == error_type 
        idle(wrongChoice_delay);  %100 %Previously 1100              % Clear screens
    elseif 3 == error_type || 4 == error_type % Break fixation during sample time or delay time
        idle(fixBreak_delay) %20 % 2000 previously
    else
        idle(0)
    end
end
trialerror(error_type);
