if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(70, ''juiceline'', 1, ''eventmarker'', 100);');   % manual reward
TrialRecord.MarkSkippedFrames = false;  % skip skipped frame markers

dashboard(4,'Move: Left click + Drag',[0 1 0]);
dashboard(5,'Resize: Right click + Drag',[0 1 0]);
dashboard(6,'Press ''x'' to quit.',[1 0 0]);

mouse_.showcursor(false);  % hide the mouse cursor from the subject


% parameters for grating
if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else radius = 1; end
if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else direction = 0; end
%if isfield(TrialRecord.User,'speed'), speed = TrialRecord.User.speed; else speed = 1; end
%if isfield(TrialRecord.User,'NumDot'), NumDot = TrialRecord.User.NumDot; else NumDot = 100; end




fixation_point = 1;
reward = 50;


fix = SingleTarget(eye_);
fix.Target = fixation_point;   
fix.Threshold = 1.5;
wth = WaitThenHold(fix);
wth.WaitTime = 5000;
wth.HoldTime = 0;
scene0 = create_scene(wth, 1);

delay_before_rwd = 500;
rwd = RewardScheduler(fix);  
rwd.Schedule = [delay_before_rwd 1600 1600 100 90];
lh = LooseHold(rwd);  
lh.HoldTime = 10000;
lh.BreakTime = 0;

% editables
Coherence = 100; %[0,100]
NumDot = 60;
DotSize = 0.15;
DotColor = [0 0 0];
DotShape = {'Square','Circle','Square'};
editable('Coherence','DotSize','-color','DotColor','-category','DotShape');

% rdm
rdm = RDM_RF_Mapper(mouse_);
rdm.Position = position;
rdm.Radius = radius;
rmd.direction = direction;
%rdm.Speed = speed;
rdm.NumDot = NumDot;

rdm.Coherence = Coherence;
rdm.DotSize = DotSize;
rdm.DotColor = DotColor;
rdm.DotShape = DotShape{2};
rdm.InfoDisplay = true;

% create the scene with concurrent
con = Concurrent(lh);
con.add(rdm);
scene1 = create_scene(con, 1);





error_type = 0;
run_scene(scene0,10);
if wth.Success 
    %goodmonkey(reward, 'eventmarker', 100, 'nonblocking', 2);
    run_scene(scene1,20);
    
    if lh.Success
        %goodmonkey(reward, 'eventmarker', 100);% Task fully completed
    else
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end

idle(0); % clear screen
trialerror(error_type);
TrialRecord.User.position = rdm.Position;
TrialRecord.User.radius = rdm.Radius;
TrialRecord.User.direction = rmd.direction;
TrialRecord.User.speed = rdm.Speed;
%TrialRecord.User.NumDot = rdm.NumDot;




if error_type == 0
    set_iti(50)
else
    set_iti(1000)
end

% save parameters
bhv_variable('position',rdm.Position);
bhv_variable('radius',rdm.Radius);
bhv_variable('direction',fi(rdm.Direction<0,rdm.Direction+360,rdm.Direction));
bhv_variable('speed',rdm.Speed);
bhv_variable('NumDot',rdm.NumDot);


