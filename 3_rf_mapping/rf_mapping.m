% if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(70, ''juiceline'', 1, ''eventmarker'', 100);');   % manual reward
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');

if exist('eye_','var'), tracker = eye_;
elseif exist('eye2_','var'), tracker = eye2_;
elseif exist('joy_','var'), tracker = joy_; showcursor(true);
elseif exist('joy2_','var'), tracker = joy2_; showcursor2(true);
else, error('This demo requires eye or joystick input. Please set it up or turn on the simulation mode.');
end

bhv_code(10,'Fixation',20,'Stimulus', 30, 'EndStimulus', 100,'Reward');
%editable('fix_rad','reward', 'reward_interval','grid_min','grid_max','stim_size','stim_time')
fixation_point = 1;

mouse_.showcursor(false);  % hide the mouse cursor from the subject

rf = [0.0 0.0];


% x_pert = (-2.25:0.5:2.25)'; % for 0.5 degree
% y_pert = (-2.25:0.5:2.25)';


x_pert = (-4.5:1:4.5)'; % for one degreee
y_pert = (-4.5:1:4.5)';

%x_pert = (-9:2:9)'; % for 2 deg of size
%y_pert = (-9:2:9)';

prior_delay = 500;
stim_time = 100;
stim_frame = 6;
reward = 50;

x_suffle = x_pert(randperm(length(x_pert)));
y_suffle = y_pert(randperm(length(y_pert)));

x = x_suffle + rf(1);
y = y_suffle+rf(2);
box_pos = [x y];
time = ones(length(x_pert), 1)*stim_frame;

box_size = 1.0;  %sqrt(rf(1)^2 + rf(2)^2);

bhv_variable('rf', rf)
bhv_variable('box_pos', box_pos);
bhv_variable('box_size', box_size);




fix = SingleTarget(eye_);
fix.Target = fixation_point;   
fix.Threshold = 1.5;
wth = WaitThenHold(fix);
wth.WaitTime = 5000;
wth.HoldTime = prior_delay;
scene0 = create_scene(wth, 1);

lh = LooseHold(fix);  
lh.HoldTime = stim_time*length(time); % HoldTime should be the duration stimulus is presented
lh.BreakTime = 0;

box = BoxGraphic(null_);
box.EdgeColor = [0 0 0];
box.FaceColor = [0.01 0.01 0.01];
box.Size = [box_size box_size];
box.Position = rf;



ct = CurveTracer(lh);
ct.Target = box;   % TaskObject#1
ct.List = [x y time];
ct.DurationUnit = 'frame';


con = Concurrent(lh);
con.add(ct);
scene1 = create_scene(con, 1);




error_type = 0;
run_scene(scene0,10);
if wth.Success 
    %goodmonkey(reward, 'eventmarker', 100, 'nonblocking', 2);
    run_scene(scene1,20);
    if ct.Success % this part never executes
        eventmarker(30);
    end
    if lh.Success
        goodmonkey(reward, 'eventmarker', 100);% Task fully completed
    else
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end


idle(0); % clear screen
trialerror(error_type);
if error_type == 0
    set_iti(100)
else
    set_iti(1000)
end

