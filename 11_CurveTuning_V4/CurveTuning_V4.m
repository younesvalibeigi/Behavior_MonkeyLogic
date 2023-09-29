if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');

bhv_code(20, 'Fixation', 50, 'Stimulus', 30, 'delay', 90, 'Reward')
fix_eventmaker = 20;
stim_eventmaker = 50;
delay_eventmaker = 30;
reward_eventmaker = 90;


editable('reward','stim_time')
fixation_point = 1;
% Timing
wait_time = 20000;
fix_rad = 1.5;
delay = 100;
reward = 60; % if reward = 30 & reward-duration = 20 then each reward transfer 0.0411 ml water
reward_interval = 25;
stim_time = 100;


prbe_stim_matrix = (2:11)';
random_prob_loc = prbe_stim_matrix(randperm(size(prbe_stim_matrix, 1)), :);
prob_stimulus = random_prob_loc(1:10,:);

initial_fix = (200:50:400)';
random_initial_fix = initial_fix(randperm(size(initial_fix, 1)), :);
initial_fix_rand = 300;%random_initial_fix(1,:);

TrialRecord.User.prob_stimulus = prob_stimulus;
bhv_variable('prob_stimulus', TrialRecord.User.prob_stimulus);

% scene 1: fixation
fix0 = SingleTarget(eye_);
fix0.Target = fixation_point; 
fix0.Threshold = fix_rad;
wth0 = WaitThenHold(fix0);
wth0.WaitTime = wait_time;
wth0.HoldTime = initial_fix_rand;
scene0 = create_scene(wth0, fixation_point);

% scene 1: sample1
fix1 = SingleTarget(eye_);
fix1.Target = fixation_point; 
fix1.Threshold = fix_rad;
wth1 = WaitThenHold(fix1);
wth1.WaitTime = 0;
wth1.HoldTime = stim_time;
scene1 = create_scene(wth1, [fixation_point prob_stimulus(1,:)]);
% scene 01: delay1
fix01 = SingleTarget(eye_);
fix01.Target = fixation_point;
fix01.Threshold = fix_rad;
wth01 = WaitThenHold(fix01);
wth01.WaitTime = 0;
wth01.HoldTime = delay;
scene01 = create_scene(wth01,fixation_point);

% scene 2: sample2
fix2 = SingleTarget(eye_);
fix2.Target = fixation_point; 
fix2.Threshold = fix_rad;
wth2 = WaitThenHold(fix2);
wth2.WaitTime = 0;
wth2.HoldTime = stim_time;
scene2 = create_scene(wth2, [fixation_point prob_stimulus(2,:)]);
% scene 02: delay2
fix02 = SingleTarget(eye_);
fix02.Target = fixation_point;
fix02.Threshold = fix_rad;
wth02 = WaitThenHold(fix02);
wth02.WaitTime = 0;
wth02.HoldTime = delay;
scene02 = create_scene(wth02,fixation_point);

% scene 3: sample3
fix3 = SingleTarget(eye_);
fix3.Target = fixation_point; 
fix3.Threshold = fix_rad;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = stim_time;
scene3 = create_scene(wth3, [fixation_point prob_stimulus(3,:)]);
% scene 03: delay3
fix03 = SingleTarget(eye_);
fix03.Target = fixation_point;
fix03.Threshold = fix_rad;
wth03 = WaitThenHold(fix03);
wth03.WaitTime = 0;
wth03.HoldTime = delay;
scene03 = create_scene(wth03,fixation_point);


% scene 4: sample4
fix4 = SingleTarget(eye_);
fix4.Target = fixation_point; 
fix4.Threshold = fix_rad;
wth4 = WaitThenHold(fix4);
wth4.WaitTime = 0;
wth4.HoldTime = stim_time;
scene4 = create_scene(wth4, [fixation_point prob_stimulus(4,:)]);
% scene 04: delay4
fix04 = SingleTarget(eye_);
fix04.Target = fixation_point;
fix04.Threshold = fix_rad;
wth04 = WaitThenHold(fix04);
wth04.WaitTime = 0;
wth04.HoldTime = delay;
scene04 = create_scene(wth04,fixation_point);

% scene 5: sample5
fix5 = SingleTarget(eye_);
fix5.Target = fixation_point; 
fix5.Threshold = fix_rad;
wth5 = WaitThenHold(fix5);
wth5.WaitTime = 0;
wth5.HoldTime = stim_time;
scene5 = create_scene(wth5, [fixation_point prob_stimulus(5,:)]);

% scene 05: delay5
fix05 = SingleTarget(eye_);
fix05.Target = fixation_point;
fix05.Threshold = fix_rad;
wth05 = WaitThenHold(fix05);
wth05.WaitTime = 0;
wth05.HoldTime = delay;
scene05 = create_scene(wth05,fixation_point);


% scene 6: sample6
fix6 = SingleTarget(eye_);
fix6.Target = fixation_point; 
fix6.Threshold = fix_rad;
wth6 = WaitThenHold(fix6);
wth6.WaitTime = 0;
wth6.HoldTime = stim_time;
scene6 = create_scene(wth6, [fixation_point prob_stimulus(6,:)]);
% scene 06: delay6
fix06 = SingleTarget(eye_);
fix06.Target = fixation_point;
fix06.Threshold = fix_rad;
wth06 = WaitThenHold(fix06);
wth06.WaitTime = 0;
wth06.HoldTime = delay;
scene06 = create_scene(wth06,fixation_point);

% scene 7: sample7
fix7 = SingleTarget(eye_);
fix7.Target = fixation_point; 
fix7.Threshold = fix_rad;
wth7 = WaitThenHold(fix7);
wth7.WaitTime = 0;
wth7.HoldTime = stim_time;
scene7 = create_scene(wth7, [fixation_point prob_stimulus(7,:)]);
% scene 07: delay7
fix07 = SingleTarget(eye_);
fix07.Target = fixation_point;
fix07.Threshold = fix_rad;
wth07 = WaitThenHold(fix07);
wth07.WaitTime = 0;
wth07.HoldTime = delay;
scene07 = create_scene(wth07,fixation_point);

% scene 8: sample8
fix8 = SingleTarget(eye_);
fix8.Target = fixation_point; 
fix8.Threshold = fix_rad;
wth8 = WaitThenHold(fix8);
wth8.WaitTime = 0;
wth8.HoldTime = stim_time;
scene8 = create_scene(wth8, [fixation_point prob_stimulus(8,:)]);
% scene 08: delay8
fix08 = SingleTarget(eye_);
fix08.Target = fixation_point;
fix08.Threshold = fix_rad;
wth08 = WaitThenHold(fix08);
wth08.WaitTime = 0;
wth08.HoldTime = delay;
scene08 = create_scene(wth08,fixation_point);

% scene 9: sample9
fix9 = SingleTarget(eye_);
fix9.Target = fixation_point; 
fix9.Threshold = fix_rad;
wth9 = WaitThenHold(fix9);
wth9.WaitTime = 0;
wth9.HoldTime = stim_time;
scene9 = create_scene(wth9, [fixation_point prob_stimulus(9,:)]);
% scene 09: delay9
fix09 = SingleTarget(eye_);
fix09.Target = fixation_point;
fix09.Threshold = fix_rad;
wth09 = WaitThenHold(fix09);
wth09.WaitTime = 0;
wth09.HoldTime = delay;
scene09 = create_scene(wth09,fixation_point);

% scene 10: sample10
fix10 = SingleTarget(eye_);
fix10.Target = fixation_point; 
fix10.Threshold = fix_rad;
wth10 = WaitThenHold(fix10);
wth10.WaitTime = 0;
wth10.HoldTime = stim_time;
scene10 = create_scene(wth10, [fixation_point prob_stimulus(10,:)]);
% scene 010: delay10
fix010 = SingleTarget(eye_);
fix010.Target = fixation_point;
fix010.Threshold = fix_rad;
wth010 = WaitThenHold(fix010);
wth010.WaitTime = 0;
wth010.HoldTime = delay;
scene010 = create_scene(wth010,fixation_point);



% TASK:
run_scene(scene0,fix_eventmaker);
if ~wth0.Success
    %idle(0); 
    trialerror(1);  % Success
    return
end

run_scene(scene1,stim_eventmaker);     % Run the second scene (eventmarker 20)
if ~wth1.Success          % If the WithThenHold failed,
    %idle(0);              %     that means the subject didn't keep fixation on the sample image.
    trialerror(1);        % So this is the "break fixation (3)" error.
    return
end

run_scene(scene01,delay_eventmaker);     % Run the second scene (eventmarker 20)
if ~wth01.Success          % If the WithThenHold failed,
    %idle(0);              %     that means the subject didn't keep fixation on the sample image.
    trialerror(1);        % So this is the "break fixation (3)" error.
    return
end

run_scene(scene2,stim_eventmaker); 
%goodmonkey(reward,'eventmarker',100);
if ~wth2.Success          
    %idle(0);              
    trialerror(1);        
    return
end

run_scene(scene02,delay_eventmaker);     
if ~wth02.Success         
    %idle(0);              
    trialerror(1);        
    return
end


run_scene(scene3,stim_eventmaker); 
% goodmonkey(reward,'eventmarker',100);
if ~wth3.Success          
    %idle(0);              
    trialerror(2);        
    return
end

run_scene(scene03,delay_eventmaker);     
if ~wth03.Success         
    %idle(0);              
    trialerror(2);        
    return
end

run_scene(scene4,stim_eventmaker); 
% goodmonkey(reward,'eventmarker',100);
if ~wth4.Success          
    %idle(0);              
    trialerror(3);        
    return
end

run_scene(scene04,delay_eventmaker);     
if ~wth04.Success         
    %idle(0);              
    trialerror(3);        
    return
end

run_scene(scene5,stim_eventmaker); 
goodmonkey(reward+3,'eventmarker',100);
if ~wth5.Success          
    %idle(0);              
    trialerror(4);        
    return
end

run_scene(scene05,delay_eventmaker);     
if ~wth05.Success         
    %idle(0);              
    trialerror(4);        
    return
end


run_scene(scene6,stim_eventmaker); 
% goodmonkey(reward,'eventmarker',100);
if ~wth6.Success          
    %idle(0);              
    trialerror(5);        
    return
end

run_scene(scene06,delay_eventmaker);     
if ~wth06.Success         
    %idle(0);              
    trialerror(5);        
    return
end

run_scene(scene7,stim_eventmaker); 
% goodmonkey(reward,'eventmarker',100);
if ~wth7.Success          
    %idle(0);              
    trialerror(6);        
    return
end

run_scene(scene07,delay_eventmaker);     
if ~wth07.Success         
    %idle(0);              
    trialerror(6);        
    return
end

run_scene(scene8,stim_eventmaker); 
%goodmonkey(reward+5,'eventmarker',100);
if ~wth8.Success          
    %idle(0);              
    trialerror(7);        
    return
end

run_scene(scene08,delay_eventmaker);     
if ~wth08.Success         
    %idle(0);              
    trialerror(7);        
    return
end


run_scene(scene9,stim_eventmaker); 
% goodmonkey(reward,'eventmarker',100);
if ~wth9.Success          
    %idle(0);              
    trialerror(8);        
    return
end

run_scene(scene09,delay_eventmaker);     
if ~wth09.Success         
    %idle(0);              
    trialerror(8);        
    return
end

run_scene(scene10,stim_eventmaker);
goodmonkey(reward+5,'eventmarker',100);
if ~wth10.Success          
    %idle(0);              
    trialerror(9);        
    return
end

run_scene(scene010,delay_eventmaker);     
if ~wth010.Success         
    %idle(0);              
    trialerror(9);        
    return
end
%idle(0);
error_type =0;



trialerror(error_type);
idle(0); % clear screen

if error_type == 0
    set_iti(100)
else
    set_iti(300)
end
