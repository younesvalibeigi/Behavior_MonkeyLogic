hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward', 80, 'Microstimulation1',90, 'Microstimulation2');  % behavioral codes

% detect an available tracker
if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

%Stop the program after enough number of trials
% block_num = TrialRecord.CurrentBlock;
% max_trial_toRun = 10;
% max_conditions_toRun = max_trial_toRun*length(TrialRecord.ConditionsThisBlock);
% correctTrials = sum(TrialRecord.TrialErrors == 0);
% if correctTrials>=max_conditions_toRun
%     TrialRecord.Quit = true;
%     finalMessage = 'Last Trial to run'
% end

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
sample = 2;
target = 3;
distractor = 4;

% define time intervals (in ms):
wait_for_fix = 20000;
initial_fix = 500;
sample_time = 300;%500;%1000;% 200 Pooya
delay = randi([250, 500]); %700; % random 200-500 ms --> saccade delay (monkey should  not predict time), super saccade
max_reaction_time = 3000;
hold_target_time = 800; % pooya 750 but not important, max for Arya

% fixation window (in degrees):
fix_radius = 1.9;%2;
hold_radius = 2.5;
choice_radius = 4;%2.3;

% We have used toggleobject() to present stimuli and eyejoytrack() to track
% behavior.  This method is not very advantageous in creating dynamic,
% behavior-responsive stimuli, because stimuli and behavior are processed
% separately and there is no proper way to change stimuli during behavior
% tracking.  While we can still use the old method, ML2 provides a new way
% to compose tasks which uses "adapters" as building blocks of task scenes
% and two new functions, create_scene() and run_scene(), as replacements of
% toggleobject() and eyejoytrack().
 
% The adapter is a MATLAB class objects and has two member functions,
% analyze() and draw(), that are called by run_scene() every frame.  Each
% time when they are called, analyze() examines samples acquired during the
% previous frame and draw() re-paints the screen buffer to present in the
% next frame.  Through this cycle, the adapter can analyze the subject's
% behavior and determine what to present next based on the analysis.
% Multiple adapters can be concatenated to create complex stimuli and
% detect complex behavioral patterns.

% You can make your own adapters, but there are already dozens of built-in
% adapters that allows you to do everything you could do with
% toggleobject() and eyejoytrack() and more.  By recycling the built-in
% adapters, you can be less concerned about how they internally works
% and more focused on how to build a task.  Typically the adapters have
% initial parameters that you need to set before rendering the scenes.
% Then they perform the behavior analysis or stimulus presentation during
% the scenes.  When the scenes are finished, you can read out the analysis
% results via the Success state variable or any other custom variables.

% All adapters accept another adapter as an argument at initialization.
% There are five pre-defined adapters that you can begin the adapter chain
% with: eye_, joy_, touch_, button_ and null_.  Their names indicate what
% input signal they process.

% scene 1: fixation
fix1 = SingleTarget(tracker);  % We use eye signals (eye_) for tracking. The SingleTarget adapter
fix1.Target = fixation_point;  %    examines if the gaze is in the Threshold window around the Target.
fix1.Threshold = fix_radius;   % The Target can be either TaskObject# or [x y] (in degrees).

wth1 = WaitThenHold(fix1);     % The WaitThenHold adapter waits for WaitTime until the fixation
wth1.WaitTime = wait_for_fix;  %    is acquired and then checks whether the fixation is held for HoldTime.
wth1.HoldTime = initial_fix;   % Since WaitThenHold gets the fixation status from SingleTarget,
                               % SingleTarget (fix1) must be the input argument of WaitThenHold (wth1).

scene1 = create_scene(wth1,fixation_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and wait for fixation.

% scene 2: sample
fix2 = SingleTarget(tracker);
fix2.Target = fixation_point;%sample;
fix2.Threshold = fix_radius;%hold_radius;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;             % We already knows the fixation is acquired, so we don't wait.
wth2.HoldTime = sample_time;
scene2 = create_scene(wth2,[fixation_point sample]);
%scene2 = create_scene(wth2,fixation_point);


% scene 2 with Microstimulation: sample
% fixStim = SingleTarget(tracker);
% fixStim.Target = fixation_point;%sample;
% fixStim.Threshold = fix_radius;%hold_radius;
% wthStim = WaitThenHold(fixStim);
% wthStim.WaitTime = 0;             % We already knows the fixation is acquired, so we don't wait.
% wthStim.HoldTime = sample_time;
% Microstimulation signal
ttl = TTLOutput(wth2);
ttl.Port = 1;  % TTL #1 must be assigned in the I/O menu
tc = TimeCounter(ttl);
tc.Duration = 100;
sceneStim = create_scene(ttl, [fixation_point sample]);

ttl2 = TTLOutput(wth2);
ttl2.Port = 2;  % TTL #1 must be assigned in the I/O menu
tc2 = TimeCounter(ttl2);
tc2.Duration = 100;
sceneStim2 = create_scene(ttl2, [fixation_point sample]);
%run_scene(scene);
%sceneStim = create_scene(wthStim,[fixation_point sample]);
%scene2 = create_scene(wth2,fixation_point);


% scene 3: delay
fix3 = SingleTarget(tracker);
fix3.Target = fixation_point;%sample;
fix3.Threshold = hold_radius;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = delay;
scene3 = create_scene(wth3,fixation_point);

% scene 4: choice
mul4 = MultiTarget(tracker);        % The MultiTarget adapter checks fixation acquisition for multiple targets.
mul4.Target = [target distractor];  % Target can be coordinates, like [x1 y1; x2 y2; x3 y3; ...], instead of TaskObject #.
mul4.Threshold = choice_radius;%fix_radius;
mul4.WaitTime = max_reaction_time;
mul4.HoldTime = hold_target_time;
mul4.TurnOffUnchosen = true;        % Determine whether to turn off the unchosen targets when one of the targets is chosen.
scene4 = create_scene(mul4,[target distractor]);



% TASK:
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

run_scene(scene1,10);        % Run the first scene (eventmaker 10)
if ~wth1.Success             % If the WithThenHold failed (either fixation is not acquired or broken during hold),
    if wth1.Waiting          %    check whether we were waiting for fixation.
        error_type = 1;%4;      % If so, fixation was never made and therefore this is a "no fixation (4)" error.
    else
        error_type = 2;%3;      % If we were not waiting, it means that fixation was acquired but not held,
    end                      %    so this is a "break fixation (3)" error.
end

if 0==error_type
    %run_scene(scene2,20);    % Run the second scene (eventmarker 20)
    
    % run_scene(scene2,20);    % Run the second scene (eventmarker 20) % No stimulation
    % Microstimulation
    if TrialRecord.CurrentCondition >= 49%49
        run_scene(sceneStim2, 90);
    elseif TrialRecord.CurrentCondition >= 25%25
        run_scene(sceneStim, 80);
    else
        run_scene(scene2,20);    % Run the second scene (eventmarker 20)
    end
    if ~wth2.Success         % The failure of WithThenHold indicates that the subject didn't maintain fixation on the sample image.
        error_type = 3;      % So it is a "break fixation (3)" error.
    end
end

if 0==error_type
    run_scene(scene3,30);    % Run the third (delay) scene (eventmarker 30)
    if ~wth3.Success
        error_type = 4;%3;      % break fixation (3)
    end
end

if 0==error_type
    t_target = run_scene(scene4,40);    % Run the fourth scene (eventmarker 40)
    if mul4.Success
        rt = mul4.RT;        % Assign rt for the reaction time graph. The same as rt = mul4.AcquiredTime - t_target;
        if target~=mul4.ChosenTarget
            error_type = 5;%6;  % One of the images was selected, but it was an incorrect choice.
        end
    else                     % The failure of MultiTarget means that none of the targets was chosen.
        if mul4.Waiting      % If we were waiting for the target selection (in other words, the gaze did not
            error_type = 6;%2;  % land on either the target or distractor), it is a "late response (2)" error.
        else
            error_type = 7;%3;  % Otherwise, the fixation is broken (3) and the choice was not held to the end.
        end
    end
end

% reward
errors = TrialRecord.TrialErrors;
curr_cond = TrialRecord.CurrentCondition;
cond_cir_easy = false;%curr_cond==1 || curr_cond==2 || curr_cond==5 || curr_cond==6;
cond_rad_diff = false;%curr_cond==15 || curr_cond==16 || curr_cond==19 || curr_cond==20 || curr_cond==23 || curr_cond==24;


if 0==error_type
    idle(0);                 % Clear screens
    %Gradually increasing num of juice rewards.
%     if length(errors) >= 3 && errors(end) == 0 && errors(end-1) == 0 && errors(end-2) == 0 %last three trials %length(errors) >= 6 && errors(end) == 0 && errors(end-1) == 0 && errors(end-2) == 0 && errors(end-3) == 0 && errors(end-4) == 0 && errors(end-5) == 0 % last five trials
%         if (cond_cir_easy || cond_rad_diff)
%             goodmonkey(75, 'juiceline',1, 'numreward',4, 'pausetime',200, 'eventmarker',50);
%         else
%             goodmonkey(75, 'juiceline',1, 'numreward',3, 'pausetime',200, 'eventmarker',50); % 100 ms of juice x 2
%         end
%     elseif length(errors) >= 2 && errors(end) == 0 && errors(end-1) == 0 %last two trials  %length(errors) >= 3 && errors(end) == 0 && errors(end-1) == 0 && errors(end-2) == 0 % last three trials
%         if (cond_cir_easy || cond_rad_diff)
%             goodmonkey(75, 'juiceline',1, 'numreward',3, 'pausetime',200, 'eventmarker',50);
%         else
%             goodmonkey(75, 'juiceline',1, 'numreward',2, 'pausetime',200, 'eventmarker',50); % 100 ms of juice x 2
%             %goodmonkey(75, 'juiceline',1, 'numreward',2, 'pausetime',200, 'eventmarker',50); % --> original one
%         end
%     else
%         if (cond_cir_easy || cond_rad_diff)
%             goodmonkey(75, 'juiceline',1, 'numreward',1, 'pausetime',200, 'eventmarker',50);
%         else
%             goodmonkey(75, 'juiceline',1, 'numreward',1, 'pausetime',200, 'eventmarker',50);
%         end
%     end
    % give juice with random number of drops.
    % Define the numbers and their corresponding probabilities
    numbers = [0, 1, 2, 3, 4];
    probabilities = [0.05, 0.75, 0.15, 0.04 0.01];
    % Sample a number based on the specified probabilities
    num_juice = randsample(numbers, 1, true, probabilities);
    goodmonkey(75, 'juiceline',1, 'numreward',num_juice, 'pausetime',200, 'eventmarker',50);


elseif 5 == error_type % choosing the distractor    || 6 == error_type || 7 == error_type 
    idle(100);  %Previously 1100              % Clear screens
elseif 3 == error_type || 4 == error_type % Break fixation during sample time or delay time
    idle(20) % 2000 previously
else
    idle(0)
end

trialerror(error_type);      % Add the result to the trial history

% Ending task
total_num_fullSets = 5;

num_levels = 6;
num_sets = 3;
N=num_levels*4*num_sets;
%errors = TrialRecord.TrialErrors;
if length(errors) > 3
    errors_0 = errors(errors == 0);
    errors_5 = errors(errors == 5);
    if (length(errors_0)+length(errors_5))>(total_num_fullSets*N)+5 % five extra for safety
        %escape_screen();
    end
end
