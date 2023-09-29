%% Qualitative Receptive Field Mapping
%file_addr_name = convertCharsToStrings(fileread('C:\Users\labuser\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Younes\file_name.txt'));
cc=0;

if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu.'); end
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('s', 'displayRF(grat2b.Position, grat2b.Radius, file_addr_name);');

bhv_code(10,'Scene 1',20,'Scene 2',90,'Reward',95,' Large Reward');

dashboard(3,'This task allows you to change the grating with mouse and keyboard while tracking eye.',[0 1 0]);
dashboard(4,'Press ''q'' to quit.',[1 0 0]);
dashboard(5,'Press ''s'' to print RF info.',[1 0 0]);


mouse_.showcursor(false);  % hide the mouse cursor from the subject

% parameters for grating
if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else radius = 1; end
if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else direction = 0; end
if isfield(TrialRecord.User,'sfreq'), sfreq = TrialRecord.User.sfreq; else sfreq = 1; end
if isfield(TrialRecord.User,'tfreq'), tfreq = TrialRecord.User.tfreq; else tfreq = 3.2; end

% editables
SpatialFrequencyStep = 0.1;
TemporalFrequencyStep = 0.1;
editable('SpatialFrequencyStep','TemporalFrequencyStep');

% scene1
fix1 = SingleTarget(eye_);
fix1.Target = 1;
fix1.Threshold = 1.5;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 5000;
wth1.HoldTime = 0;
scene1 = create_scene(wth1,1);

% scene2
rwd2a = RewardScheduler(fix1);  
rwd2a.Schedule = [1500 1500 1800 60 90];  % during fixation, give a 100-ms reward every seconds
    %5000 1000 1000 150 95];            % if fix is maintained longer than 5000 ms, increase the reward to 150 ms
lh2a = LooseHold(rwd2a);  % lh2a stops when fixation is maintained for 10 s or broken longer than 300 ms.
lh2a.HoldTime = 50000;
lh2a.BreakTime = 0;

grat2b = Grating_RF_Mapper(mouse_);
grat2b.Position = position;
grat2b.Radius = radius;
grat2b.Direction = direction;
grat2b.SpatialFrequency = sfreq;
grat2b.TemporalFrequency = tfreq;
grat2b.SpatialFrequencyStep = SpatialFrequencyStep;
grat2b.TemporalFrequencyStep = TemporalFrequencyStep;
grat2b.InfoDisplay = true;

con2 = Concurrent(lh2a);   % The Concurrent adapter continues, if lh2a continues, and run grat2b additionally.
con2.add(grat2b);          % grat2b does not stop the scene.

scene2 = create_scene(con2,1);

% run the task
error_type = 0;
run_scene(scene1,10);

if wth1.Success
    run_scene(scene2,20);
    if ~lh2a.Success
        error_type = 3;  % fix break
    end
else
    error_type = 4;  % no fixation
end
idle(0);

trialerror(error_type);
%set_iti(500);

% record keeping
trialerror(error_type);
TrialRecord.User.position = grat2b.Position;
TrialRecord.User.radius = grat2b.Radius;
TrialRecord.User.direction = grat2b.Direction;
TrialRecord.User.sfreq = grat2b.SpatialFrequency;
TrialRecord.User.tfreq = grat2b.TemporalFrequency;

if error_type == 0
    set_iti(50)
else
    set_iti(100)
end
