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
fix_rad = 1.7;
delay = 200;
reward = 60; % if reward = 30 & reward-duration = 20 then each reward transfer 0.0411 ml water
reward_interval = 25;
stim_time = 200;


prbe_stim_matrix = [2 2 2 2 2]';
random_prob_loc = prbe_stim_matrix(randperm(size(prbe_stim_matrix, 1)), :);
prob_stimulus = random_prob_loc(1:5,:);

initial_fix = (200:50:400)';
random_initial_fix = initial_fix(randperm(size(initial_fix, 1)), :);
initial_fix_rand = 300;%random_initial_fix(1,:);

TrialRecord.User.prob_stimulus = prob_stimulus;
bhv_variable('prob_stimulus', TrialRecord.User.prob_stimulus);

% scene 1: fixation
fix = SingleTarget(eye_);
fix.Target = fixation_point; 
fix.Threshold = fix_rad;
wth0 = WaitThenHold(fix);
wth0.WaitTime = wait_time;
wth0.HoldTime = initial_fix_rand;
scene0 = create_scene(wth0, fixation_point);

% scene 1: sample1
wth1 = WaitThenHold(fix);
wth1.WaitTime = 0;
wth1.HoldTime = stim_time;
scene1 = create_scene(wth1, [fixation_point prob_stimulus(1,:)]);
% scene 01: delay1
wth01 = WaitThenHold(fix);
wth01.WaitTime = 0;
wth01.HoldTime = delay;
scene01 = create_scene(wth01,fixation_point);

% scene 2: sample2
wth2 = WaitThenHold(fix);
wth2.WaitTime = 0;
wth2.HoldTime = stim_time;
scene2 = create_scene(wth2, [fixation_point prob_stimulus(2,:)]);
% scene 02: delay2
wth02 = WaitThenHold(fix);
wth02.WaitTime = 0;
wth02.HoldTime = delay;
scene02 = create_scene(wth02,fixation_point);

% scene 3: sample3
wth3 = WaitThenHold(fix);
wth3.WaitTime = 0;
wth3.HoldTime = stim_time;
scene3 = create_scene(wth3, [fixation_point prob_stimulus(3,:)]);
% scene 03: delay3
wth03 = WaitThenHold(fix);
wth03.WaitTime = 0;
wth03.HoldTime = delay;
scene03 = create_scene(wth03,fixation_point);


% scene 4: sample4
wth4 = WaitThenHold(fix);
wth4.WaitTime = 0;
wth4.HoldTime = stim_time;
scene4 = create_scene(wth4, [fixation_point prob_stimulus(4,:)]);
% scene 04: delay4
wth04 = WaitThenHold(fix);
wth04.WaitTime = 0;
wth04.HoldTime = delay;
scene04 = create_scene(wth04,fixation_point);

% scene 5: sample5 
wth5 = WaitThenHold(fix);
wth5.WaitTime = 0;
wth5.HoldTime = stim_time;
scene5 = create_scene(wth5, [fixation_point prob_stimulus(5,:)]);

% scene 05: delay5 ---------> There is no need for this last delay
wth05 = WaitThenHold(fix);
wth05.WaitTime = 0;
wth05.HoldTime = delay;
scene05 = create_scene(wth05,fixation_point);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Task:
% 2 image
error_type = 0;
run_scene(scene0,fix_eventmaker);
if ~wth0.Success
    error_type = 1;
else
    run_scene(scene1,stim_eventmaker);
    if ~wth1.Success
        error_type = 1;
    else
        %goodmonkey(reward+3,'eventmarker',100);
        %error_type = 0;
        run_scene(scene03, delay_eventmaker);
        if ~wth1.Success
            error_type = 2;
        else
            goodmonkey(reward+3,'eventmarker',100);
            error_type = 0;
        end


%         run_scene(scene2,stim_eventmaker);
%         if ~wth2.Success 
%             error_type = 1; % Did not see two, only see one
%         else
%             goodmonkey(reward+3,'eventmarker',100);
%             error_type = 2; % see for two seconds
%             run_scene(scene02, delay_eventmaker); % 1s delay
%             if ~wth02.Success
%                 error_type = 2;
%             else
%                 goodmonkey(reward+3,'eventmarker',100);
%                 error_type = 0;
%             end
%         end
    end
end
% error 1, no fixation or only fixation and see for 1 s
% error 2, saw for 2 s
% error 0, stay fixated for the 1s delay as well.


% % 3 s stimulus
% error_type = 0;
% run_scene(scene0,fix_eventmaker);
% if ~wth0.Success
%     error_type = 1;
% else
%     run_scene(scene1,stim_eventmaker);
%     if ~wth1.Success
%         error_type = 1;
%     else
%         goodmonkey(reward+3,'eventmarker',100);
%         run_scene(scene2,stim_eventmaker);
%         if ~wth2.Success 
%             error_type = 1; % Did not see two, only see one
%         else
%             goodmonkey(reward+3,'eventmarker',100);
%             run_scene(scene3,stim_eventmaker); 
%             if ~wth3.Success
%                 error_type = 2; % Did not see 3, only see 1 and 2
%             else
%                 goodmonkey(reward+3,'eventmarker',100);
%                 error_type = 3;
%                 run_scene(scene03, delay_eventmaker);
%                 if ~wth03.Success
%                     error_type = 3;
%                 else
%                     goodmonkey(reward+3,'eventmarker',100);
%                     error_type = 0;
%                 end
%             end
%         end
%     end
% end
% % error 1, no fixation or only fixation
% % error 2, saw for 2 s
% % error 3, saw for complete three seconds
% % error 0, stay fixated for the 1s delay as well.


% five seconds


% error_type = 0;
% run_scene(scene0,fix_eventmaker);
% if ~wth0.Success
%     error_type = 1;
% else
%     run_scene(scene1,stim_eventmaker);
%     if ~wth1.Success
%         error_type = 1;
%     else
%         goodmonkey(reward+3,'eventmarker',100);
%         run_scene(scene2,stim_eventmaker);
%         if ~wth2.Success 
%             error_type = 1; % Did not see two, only see one
%         else
%             goodmonkey(reward+3,'eventmarker',100);
%             run_scene(scene3,stim_eventmaker); 
%             if ~wth3.Success
%                 error_type = 2; % Did not see 3, only see 1 and 2
%             else
%                 goodmonkey(reward+3,'eventmarker',100);
%                 run_scene(scene4,stim_eventmaker);
%                 if ~wth4.Success
%                     error_type = 3;
%                 else
%                     goodmonkey(reward+3,'eventmarker',100);
%                     run_scene(scene5,stim_eventmaker);
%                     if ~wth5.Success
%                         error_type = 4;
%                     else
%                         goodmonkey(reward+3,'eventmarker',100);
%                         error_type = 0; % End of the task
%                     end
%                 end
%             end
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % error
% % 1 fixation and see image 1
% % 2 saw image 2
% % 3 saw image 3
% % 4 Saw 4 images
% % 0 Task completed saw the full five image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idle(0); % clear screen
trialerror(error_type);
if error_type == 0
    set_iti(100)
else
    set_iti(800)
end
