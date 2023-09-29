if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Scene 1',20,'Scene 2',90,'Reward',95,' Large Reward');

dashboard(3,'This task allows you to change the grating with mouse and keyboard while tracking eye.',[0 1 0]);
dashboard(4,'Press ''x'' to quit.',[1 0 0]);

mouse_.showcursor(false);  % hide the mouse cursor from the subject

% parameters for grating
% if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
% if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else radius = 1; end
% if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else direction = 0; end
% if isfield(TrialRecord.User,'sfreq'), sfreq = TrialRecord.User.sfreq; else sfreq = 1; end
% if isfield(TrialRecord.User,'tfreq'), tfreq = TrialRecord.User.tfreq; else tfreq = 1; end

% editables
% SpatialFrequencyStep = 0.1;
% TemporalFrequencyStep = 0.1;
% editable('SpatialFrequencyStep','TemporalFrequencyStep');

delay = 500;
stim_time = 2000;
% scene1
fix1 = SingleTarget(eye_);
fix1.Target = 1;
fix1.Threshold = 1.75; % fixation radius in degree
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 5000;
wth1.HoldTime = delay; %Delay
scene1 = create_scene(wth1,1);

% scene2
rwd2a = RewardScheduler(fix1);  
rwd2a.Schedule = [500 1000 1000 50 90];  % during fixation, give a 100-ms reward every seconds
    %5000 1000 1000 150 95];            % if fix is maintained longer than 5000 ms, increase the reward to 150 ms
lh2a = LooseHold(rwd2a);  % lh2a stops when fixation is maintained for stim_time s or broken longer than 300 ms.
lh2a.HoldTime = stim_time;
lh2a.BreakTime = 0;

scene2 = create_scene(lh2a,1);

% grat2b = Grating_RF_Mapper(mouse_);
% grat2b.Position = position;
% grat2b.Radius = radius;
% grat2b.Direction = direction;
% grat2b.SpatialFrequency = sfreq;
% grat2b.TemporalFrequency = tfreq;
% grat2b.SpatialFrequencyStep = SpatialFrequencyStep;
% grat2b.TemporalFrequencyStep = TemporalFrequencyStep;
% grat2b.InfoDisplay = true;


%---------------------------------
numDir = 8;
degrees = zeros(1, numDir);
for i = 1:16
    degrees(i) = (i-1)*360/numDir;
end


r = randi([1 numDir]);
%%%%%---------------------------------------------------------------------------------------------------------
position = [0.0, 0.0];
spatialfreq = 1;
temporalfreq = 4.2;
radius = 1.4;
phase = 0;

%save the direction
bhv_variable('direction', degrees(r));
bhv_variable('position', position);
%position is RF
bhv_variable('spatialfreq', spatialfreq);
bhv_variable('temporalfreq', temporalfreq);
bhv_variable('radius', radius);


grat1 = SineGrating(null_);
grat1.List = {position, radius, degrees(r), spatialfreq, temporalfreq, phase, '', '','circular', ''};
tc1 = TimeCounter(grat1);
tc1.Duration = 3000;
con1 = Concurrent(lh2a);   % The Concurrent adapter continues, if lh2a continues, and run grat2b additionally.
%con2.add(grat2b);          % grat2b does not stop the scene.
con1.add(tc1);
sceneC1 = create_scene(con1,1);

conArr = [];
for i=1:numDir
    grat = SineGrating(null_);
    grat.List = {position, radius, degrees(i), spatialfreq, temporalfreq, phase, '', '','circular', ''};
    tc = TimeCounter(grat);
    tc.Duration = 1000;
    con = Concurrent(lh2a);
    con.add(tc);
    %conArr(end+1)=con;
    arr = [con];
    conArr = cat(1, conArr, arr);
end

A = randperm(numDir);
% 
scene3 = create_scene(tc1,1);

grat2 = SineGrating(null_);
grat2.List = {position, radius, degrees(2), spatialfreq, temporalfreq, phase, '', '','circular', ''};
tc2 = TimeCounter(grat2);
tc2.Duration = 1000;
con2 = Concurrent(lh2a);   % The Concurrent adapter continues, if lh2a continues, and run grat2b additionally.
%con2.add(grat2b);          % grat2b does not stop the scene.
con2.add(tc2);
sceneC2 = create_scene(con2,1);
cc=0;

% run the task
% General C1--------------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    run_scene(sceneC1,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end

%{
% A1------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(1)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A2------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(2)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A3------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(3)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A4------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(4)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A5------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(5)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A6------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(6)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A7------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(7)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A8------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(8)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A9------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(9)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A10------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(10)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A11------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(11)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A12------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(12)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A13------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(13)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A14------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(14)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A15------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(15)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
% A16------------------
error_type = 0;
run_scene(scene1,10);
if wth1.Success 
    sceneC = create_scene(conArr(A(16)),1);
    run_scene(sceneC,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
%}





idle(50);

trialerror(error_type);
set_iti(1000);


