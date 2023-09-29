if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
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
rf = [-1.9,0.5];
rf_radius = 1.2; % you have to provide this
coherence = 100;%ceil(rand(1)*100);
direction = floor(rand(1)*12)*30;%rand(1)*360;
speed = 5;%1 + rand(1)*19;
% rdm variables
num_dot_b = rf_radius*10;
num_dot_w = rf_radius*10/2;
dot_size = 0.15;
dot_color = [0.0 0.0 0.0];
dot_shape = {'Square','Circle','Square'};
dot_shape = dot_shape{end};
%editable('num_dot','dot_size','-color','dot_color','-category','dot_shape');

delay_time = 500;
stim_time = 1000;
reward = 100;





%save variables
bhv_variable('rf', rf)
bhv_variable('rf_radius', rf_radius)
bhv_variable('coherence', coherence);
bhv_variable('direction', direction);
bhv_variable('speed', speed);
bhv_variable('num_dot_b', num_dot_b);
bhv_variable('num_dot_w', num_dot_w);
bhv_variable('dot_size', dot_size);
bhv_variable('dot_shape', dot_shape);



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

% rdm stim black
rdm2 = RandomDotMotion(wth2);
rdm2.NumDot = num_dot_b;
rdm2.DotSize = dot_size;
rdm2.DotColor = dot_color;
rdm2.DotShape = dot_shape;
rdm2.Position = rf;
rdm2.Radius = rf_radius;
rdm2.Coherence = coherence;
rdm2.Direction = direction;
rdm2.Speed = speed;
% rdm stim white
rdm3 = RandomDotMotion(wth2);
rdm3.NumDot = num_dot_w;
rdm3.DotSize = dot_size;
rdm3.DotColor = [1 1 1];
rdm3.DotShape = dot_shape;
rdm3.Position = rf;
rdm3.Radius = rf_radius;
rdm3.Coherence = coherence;
rdm3.Direction = direction;
rdm3.Speed = speed;

con = Concurrent(rdm2);
con.add(rdm3);

scene2 = create_scene(con,fixation_point);

% task
dashboard(1,sprintf('Coherence = %d',coherence));
dashboard(2,sprintf('Direction = %.1f deg',direction));
dashboard(3,sprintf('Speed = %.1f deg/sec',speed));
dashboard(4,sprintf('Dot shape = %s',dot_shape));

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
dashboard(3,'');
dashboard(4,'');


trialerror(error_type);
idle(0); % clear screen

if error_type == 0
    set_iti(100)
else
    set_iti(1000)
end