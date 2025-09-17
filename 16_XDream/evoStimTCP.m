% === 10-image train, ML2 adapter pattern, TTL at each stimulus onset ===
if ~exist('eye_','var'), error('This task requires an eye signal (or simulation mode).'); end
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% ---- Event codes ----
bhv_code(20,'Fixation', 30,'Delay', 90,'Reward', ...
         21,'Img1',22,'Img2',23,'Img3',24,'Img4',25,'Img5', ...
         26,'Img6',27,'Img7',28,'Img8',29,'Img9',30,'Img10');

fix_eventmarker   = 20;
delay_eventmarker = 30;
reward_eventmaker = 90;

% ---- Tracker detection (ML2) ----
if     exist('eye_','var'),   tracker = eye_;
elseif exist('eye2_','var'),  tracker = eye2_;
elseif exist('joy_','var'),   tracker = joy_;  showcursor(true);
elseif exist('joy2_','var'),  tracker = joy2_; showcursor2(true);
else, error('No valid tracker (eye/joystick) found or simulation mode off.');
end

% ---- TaskObjects ----
fixation_point = 1;                  % TaskObject #1 = fixation
% Images are TaskObject #2..#11 (10 images total)
prob_stimulus = (2:11)';             % Use your own order or randomize if desired
% prob_stimulus = prob_stimulus(randperm(numel(prob_stimulus))); % (optional)
%disp(Screen.RefreshRate)               % in hertz
%disp(Screen.FrameLength)               % in milliseconds)
frameLength = Screen.FrameLength;
% ---- Timing (ms) ----
wait_for_fix = 20000;
initial_fix  = frameLength*6; % 100                 % pre-fix hold before the train
stim_time    = frameLength*6; % 100                 % ON 100 ms
delay_time   = frameLength*6; % 100                 % OFF 100 ms (between images)
fix_radius   = 1.6;
hold_radius  = 1.9;
choice_radius = 3; %#ok<NASGU>      % not used here, kept for consistency

% ---- TTL config ----
ttl_port     = 1;                    % Port 1 in I/O menu
ttl_duration = frameLength;                   % 16.6667 ms pulse at each image onset

% Expose a couple variables to BHV for logging
bhv_variable('stim_time',stim_time,'delay_time',delay_time,'ttl_port',ttl_port,'ttl_duration',ttl_duration);

% ===================== SCENES =====================

% Scene 0: acquire & hold fixation before train
fix0 = SingleTarget(tracker);
fix0.Target     = fixation_point;
fix0.Threshold  = fix_radius;
wth0 = WaitThenHold(fix0);
wth0.WaitTime   = wait_for_fix;
wth0.HoldTime   = initial_fix;
scene0 = create_scene(wth0, fixation_point);

% Build 10 stimulus scenes with TTL at onset
N = 10;
stim_scenes  = cell(N,1);
stim_wth     = cell(N,1);
delay_scenes = cell(N-1,1);
delay_wth    = cell(N-1,1);

for k = 1:N
    % TTL adapter (fires at scene start)
    ttl = TTLOutput(tracker);
    ttl.Port     = ttl_port;         % [1] if only one port, can be vector if needed
    ttl.Duration = ttl_duration;     % 16.7 ms pulse

    % Fixation gate chained AFTER TTL so TTL runs concurrently with the scene
    fixK = SingleTarget(ttl);
    fixK.Target    = fixation_point;
    fixK.Threshold = hold_radius;

    wthK = WaitThenHold(fixK);
    wthK.WaitTime = 0;
    wthK.HoldTime = stim_time;       % show image for 100 ms while holding fixation
    stim_wth{k}   = wthK;

    % Present fixation + the k-th image
    stim_scenes{k} = create_scene(wthK, [fixation_point prob_stimulus(k)]);
    
    % OFF period scene (no image) after stimuli
    fixD = SingleTarget(tracker);
    fixD.Target    = fixation_point;
    fixD.Threshold = hold_radius;

    wthD = WaitThenHold(fixD);
    wthD.WaitTime = 0;
    wthD.HoldTime = delay_time;  % 100 ms OFF while holding fixation
    delay_wth{k}  = wthD;

    delay_scenes{k} = create_scene(wthD, fixation_point);
end

% ===================== TASK =====================

error_type = 0;

% Acquire fixation
run_scene(scene0, fix_eventmarker);
if ~wth0.Success
    if wth0.Waiting, error_type = 1; else, error_type = 2; end
end

% Stimulus train: 10 images with 100 ms ON & 100 ms OFF
num_TTL = 0;
if 0==error_type
    for k = 1:N
        % Unique event code per image: 21..30
        img_event = 20 + k;
        run_scene(stim_scenes{k}, img_event);
        % keep track of number of images shown
        num_TTL = num_TTL +1;

        if ~stim_wth{k}.Success
            error_type = 3;   % broke fixation during stimulus
            bhv_variable('num_TTL', num_TTL);
            TrialRecord.User.num_TTL = num_TTL;
            break
        end
        % The delay period
        run_scene(delay_scenes{k}, delay_eventmarker);
        if ~delay_wth{k}.Success
            error_type = 4;  % broke fixation during OFF
            bhv_variable('num_TTL', num_TTL);
            TrialRecord.User.num_TTL = num_TTL;
            break
        end
        
    end
end
bhv_variable('num_TTL', num_TTL);
TrialRecord.User.num_TTL = num_TTL;

% Reward & end
idle(0);  % clear screen
if 0==error_type
    numbers = [0, 1, 2, 3, 4];
    probabilities = [0.01, 0.79, 0.15, 0.04 0.01];
    % Sample a number based on the specified probabilities
    num_juice = randsample(numbers, 1, true, probabilities);
    pauseTime = frameLength*12; %% 200
    goodmonkey(75, 'juiceline',1, 'numreward',num_juice, 'pausetime',pauseTime, 'eventmarker',reward_eventmaker);

    %goodmonkey(60, 'juiceline',1, 'numreward',1, 'pausetime',200, 'eventmarker',reward_eventmaker);
% else
%     idle(frameLength);
end

trialerror(error_type);
set_iti(0)
%set_iti( (error_type==0) * 10 + (error_type~=0) * 500 );
