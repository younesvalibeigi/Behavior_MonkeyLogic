% if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(70, ''juiceline'', 1, ''eventmarker'', 100);');   % manual reward

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

rf = [-2.3 -1];

box_size = 2.0;  %sqrt(rf(1)^2 + rf(2)^2);

% x_pert = (-2.25:0.5:2.25)'; % for 0.5 degree
% y_pert = (-2.25:0.5:2.25)';


% x_pert = (-4.5:1:4.5)'; % for one degreee
% y_pert = (-4.5:1:4.5)';

x_pert = (-9:2:9)'; % for 2 deg of size
y_pert = (-9:2:9)';




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

% Color (0 black, 1 white)
color =  arrayfun(@(x) {(x==0)*[0 0 0] + (x==1)*[1 1 1]}, randi([0 1], 1, 10));

box_cell = cell(10,4);
for i = 1:10
    box_cell{i,1} = color{i};
    box_cell{i,2} = color{i};
    box_cell{i,3} = [box_size box_size];
    box_cell{i,4} = box_pos(i,:);
end

bhv_variable('rf', rf)
bhv_variable('box_pos', box_pos);
bhv_variable('box_size', box_size);
bhv_variable('color', color);




fix = SingleTarget(eye_);
fix.Target = fixation_point;   
fix.Threshold = 1.5;
wth = WaitThenHold(fix);
wth.WaitTime = 5000;
wth.HoldTime = prior_delay;
scene0 = create_scene(wth, 1);

wth_stim = WaitThenHold(fix);
wth_stim.WaitTime = 0;
wth_stim.HoldTime = stim_time;

lh = LooseHold(fix);  
lh.HoldTime = stim_time*length(time); % HoldTime should be the duration stimulus is presented
lh.BreakTime = 0;

box1 = BoxGraphic(wth_stim);
box1.List = box_cell(1,:);
scene1 = create_scene(box1, 1);

box2 = BoxGraphic(wth_stim);
box2.List = box_cell(2,:);
scene2 = create_scene(box2, 1);

box3 = BoxGraphic(wth_stim);
box3.List = box_cell(3,:);
scene3 = create_scene(box3, 1);

box4 = BoxGraphic(wth_stim);
box4.List = box_cell(4,:);
scene4 = create_scene(box4, 1);

box5 = BoxGraphic(wth_stim);
box5.List = box_cell(5,:);
scene5 = create_scene(box5, 1);

box6 = BoxGraphic(wth_stim);
box6.List = box_cell(6,:);
scene6 = create_scene(box6, 1);

box7 = BoxGraphic(wth_stim);
box7.List = box_cell(7,:);
scene7 = create_scene(box7, 1);

box8 = BoxGraphic(wth_stim);
box8.List = box_cell(8,:);
scene8 = create_scene(box8, 1);

box9 = BoxGraphic(wth_stim);
box9.List = box_cell(9,:);
scene9 = create_scene(box9, 1);

box10 = BoxGraphic(wth_stim);
box10.List = box_cell(10,:);
scene10 = create_scene(box10, 1);
%box.EdgeColor = [0 0 0];
%box.FaceColor = [0.01 0.01 0.01];
%box.Size = [box_size box_size];
%box.Position = rf;



% ct = CurveTracer(lh);
% ct.Target = box;   % TaskObject#1
% ct.List = [x y time];
% ct.DurationUnit = 'frame';
% 
% 
% con = Concurrent(lh);
% con.add(ct);
% scene1 = create_scene(con, 1);




error_type = 0;
run_scene(scene0,10);
if ~wth.Success
    error_type = 4;
else
    run_scene(scene1,20);
    if ~wth_stim.Success
        error_type = 3;
    else
        run_scene(scene2,20);
        if ~wth_stim.Success
            error_type = 3;
        else
            run_scene(scene3,20);
            if ~wth_stim.Success
                error_type = 3;
            else
                run_scene(scene4,20);
                if ~wth_stim.Success
                    error_type = 3;
                else
                    run_scene(scene5,20);
                    if ~wth_stim.Success
                        error_type = 3;
                    else
                        %goodmonkey(reward, 'eventmarker', 100);
                        run_scene(scene6,20);
                        if ~wth_stim.Success
                            error_type = 3;
                        else
                            run_scene(scene7,20);
                            if ~wth_stim.Success
                                error_type = 3;
                            else
                                run_scene(scene8,20);
                                if ~wth_stim.Success
                                    error_type = 3;
                                else
                                    run_scene(scene9,20);
                                    if ~wth_stim.Success
                                        error_type = 3;
                                    else
                                        goodmonkey(reward, 'eventmarker', 100);% Task fully completed
                                        run_scene(scene10,20);
                                        if ~wth_stim.Success
                                            error_type = 3;
                                        else
                                            goodmonkey(reward, 'eventmarker', 100);% Task fully completed
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

% if wth.Success 
%     %goodmonkey(reward, 'eventmarker', 100, 'nonblocking', 2);
%     run_scene(scene1,20);
%     if wth_stim.Success % this part never executes
%         run_scene(scene1,20);
%     end
%     if lh.Success
%         goodmonkey(reward, 'eventmarker', 100);% Task fully completed
%     else
%         error_type = 3;  % fix break
%     end
% else
%     error_type = 4;  % no fixation
% end


idle(0); % clear screen
trialerror(error_type);
if error_type == 0
    set_iti(0)
else
    set_iti(1000)
end



