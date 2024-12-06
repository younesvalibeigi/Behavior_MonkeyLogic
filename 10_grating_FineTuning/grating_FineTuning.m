if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(70, ''juiceline'', 1, ''eventmarker'', 100);');   % manual reward

if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

bhv_code(10,'Fixation',20,'Stimulus', 30, 'EndStimulus', 100,'Reward');

mouse_.showcursor(false);  % hide the mouse cursor from the subject


% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% info for preparing each stimulus
rf = [-5.0,-2.0];
coherence = 100;%ceil(rand(1)*100);
direction = floor(rand(1)*12)*30; % You have to provide the direction to RF map
%floor(rand(1)*12)*30;%rand(1)*360;
speed = 10;%1 + rand(1)*19;
% rdm variables
num_dot = 20;
dot_size = 0.15;
dot_color = [0.0 0.0 0.0];
dot_shape = {'Square','Circle','Square'};
dot_shape = dot_shape{end};
%editable('num_dot','dot_size','-color','dot_color','-category','dot_shape');

delay_time = 500;
stim_time = 2000;
reward = 100;

rf_radius = 4; % you have to provide this
stim_radius = rf_radius;%rf_radius/2;
%stim_pos_x = [-2*rf_radius -rf_radius 0 rf_radius 2*rf_radius] + rf(1);
%stim_pos_y = [-2*rf_radius -rf_radius 0 rf_radius 2*rf_radius] + rf(2);
% stim_pos_x = [-2*rf_radius 0 2*rf_radius] + rf(1);
% stim_pos_y = [-2*rf_radius 0 2*rf_radius] + rf(2);
stim_pos = rf;
%stim_pos = [stim_pos_x(randi(length(stim_pos_x))) stim_pos_y(randi(length(stim_pos_y)))];
curr_cond = TrialRecord.CurrentCondition;
stim_direction = (curr_cond-1)*22.5;
spatialfreq = 0.5;
temporalfreq = 1;
phase = 0;

%save variables
bhv_variable('stim_radius', stim_radius);
bhv_variable('stim_pos', stim_pos);
bhv_variable('rf', rf)
bhv_variable('stim_direction', stim_direction);
bhv_variable('spatialfreq', spatialfreq);
bhv_variable('temporalfreq', temporalfreq);





% scene 1: fixation
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point;
fix1.Threshold = 1.5;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 5000;
wth1.HoldTime = delay_time;
scene1 = create_scene(wth1,fixation_point);

% scene 2: sample
fix2 = SingleTarget(eye_);
fix2.Target = fixation_point;
fix2.Threshold = 1.5;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = stim_time;

% rdm stim
grat1 = SineGrating(wth2);
grat1.List = {stim_pos, stim_radius, stim_direction, spatialfreq, temporalfreq, phase, '', '','circular', ''};



scene2 = create_scene(grat1,fixation_point);

% task
dashboard(1,sprintf('stim_pos = %d',stim_pos));
dashboard(2,sprintf('Direction = %.1f deg',stim_direction));

error_type = 0;
run_scene(scene1, 10);
if ~wth1.Success
    if wth1.Waiting
        error_type = 4;  % no fixation
    else
        error_type = 3;  % broke fixation
    end
end

if 0==error_type
    run_scene(scene2, 20);
    if ~wth2.Success
        error_type = 3;  % broke fixation
    else
        goodmonkey(reward, 'eventmarker', 100, 'nonblocking', 2);
    end
end

rt = wth1.RT;

dashboard(1,'');
dashboard(2,'');



trialerror(error_type);
idle(0); % clear screen

if error_type == 0
    set_iti(100)
else
    set_iti(1000)
end