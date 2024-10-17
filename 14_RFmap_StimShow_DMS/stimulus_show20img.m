if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('q', 'escape_screen(); assignin(''caller'',''continue_'',false);');

bhv_code(20, 'Fixation', 50, 'Stimulus', 30, 'delay', 90, 'Reward')
fix_eventmaker = 20;
stim_eventmaker = 50;
delay_eventmaker = 30;
reward_eventmaker = 90;


%editable('reward','stim_time')
%mouse_.showcursor(false);  % hide the mouse cursor from the subject
fixation_point = 1;
% Timing
wait_time = 20000;
fix_rad = 1.6;
delay = 0;
reward = 60; % if reward = 30 & reward-duration = 20 then each reward transfer 0.0411 ml water
reward_interval = 25;
stim_time = 100;


prbe_stim_matrix = (2:21)';
random_prob_loc = prbe_stim_matrix(randperm(size(prbe_stim_matrix, 1)), :);
prob_stimulus = prbe_stim_matrix;%random_prob_loc(1:20,:);

initial_fix = (200:50:400)';
random_initial_fix = initial_fix(randperm(size(initial_fix, 1)), :);
initial_fix_rand = random_initial_fix(1,:);

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

% scene 05: delay5
wth05 = WaitThenHold(fix);
wth05.WaitTime = 0;
wth05.HoldTime = delay;
scene05 = create_scene(wth05,fixation_point);


% scene 6: sample6
wth6 = WaitThenHold(fix);
wth6.WaitTime = 0;
wth6.HoldTime = stim_time;
scene6 = create_scene(wth6, [fixation_point prob_stimulus(6,:)]);
% scene 06: delay6
wth06 = WaitThenHold(fix);
wth06.WaitTime = 0;
wth06.HoldTime = delay;
scene06 = create_scene(wth06,fixation_point);

% scene 7: sample7
wth7 = WaitThenHold(fix);
wth7.WaitTime = 0;
wth7.HoldTime = stim_time;
scene7 = create_scene(wth7, [fixation_point prob_stimulus(7,:)]);
% scene 07: delay7
wth07 = WaitThenHold(fix);
wth07.WaitTime = 0;
wth07.HoldTime = delay;
scene07 = create_scene(wth07,fixation_point);

% scene 8: sample8
wth8 = WaitThenHold(fix);
wth8.WaitTime = 0;
wth8.HoldTime = stim_time;
scene8 = create_scene(wth8, [fixation_point prob_stimulus(8,:)]);
% scene 08: delay8
wth08 = WaitThenHold(fix);
wth08.WaitTime = 0;
wth08.HoldTime = delay;
scene08 = create_scene(wth08,fixation_point);

% scene 9: sample9
wth9 = WaitThenHold(fix);
wth9.WaitTime = 0;
wth9.HoldTime = stim_time;
scene9 = create_scene(wth9, [fixation_point prob_stimulus(9,:)]);
% scene 09: delay9
wth09 = WaitThenHold(fix);
wth09.WaitTime = 0;
wth09.HoldTime = delay;
scene09 = create_scene(wth09,fixation_point);

% scene 10: sample10
wth10 = WaitThenHold(fix);
wth10.WaitTime = 0;
wth10.HoldTime = stim_time;
scene10 = create_scene(wth10, [fixation_point prob_stimulus(10,:)]);
% scene 010: delay10 ----> There is no need for the last delay, I am not
% using it
wth010 = WaitThenHold(fix);
wth010.WaitTime = 0;
wth010.HoldTime = delay;
scene010 = create_scene(wth010,fixation_point);

% scene 11: sample11
wth11 = WaitThenHold(fix);
wth11.WaitTime = 0;
wth11.HoldTime = stim_time;
scene11 = create_scene(wth11, [fixation_point prob_stimulus(11,:)]);
% scene 011: delay11
wth011 = WaitThenHold(fix);
wth011.WaitTime = 0;
wth011.HoldTime = delay;
scene011 = create_scene(wth011,fixation_point);

% scene 12: sample12
wth12 = WaitThenHold(fix);
wth12.WaitTime = 0;
wth12.HoldTime = stim_time;
scene12 = create_scene(wth12, [fixation_point prob_stimulus(12,:)]);
% scene 012: delay12
wth012 = WaitThenHold(fix);
wth012.WaitTime = 0;
wth012.HoldTime = delay;
scene012 = create_scene(wth012,fixation_point);

% scene 13: sample13
wth13 = WaitThenHold(fix);
wth13.WaitTime = 0;
wth13.HoldTime = stim_time;
scene13 = create_scene(wth13, [fixation_point prob_stimulus(13,:)]);
% scene 013: delay13
wth013 = WaitThenHold(fix);
wth013.WaitTime = 0;
wth013.HoldTime = delay;
scene013 = create_scene(wth013,fixation_point);

% scene 14: sample14
wth14 = WaitThenHold(fix);
wth14.WaitTime = 0;
wth14.HoldTime = stim_time;
scene14 = create_scene(wth14, [fixation_point prob_stimulus(14,:)]);
% scene 014: delay14
wth014 = WaitThenHold(fix);
wth014.WaitTime = 0;
wth014.HoldTime = delay;
scene014 = create_scene(wth014,fixation_point);

% scene 15: sample15
wth15 = WaitThenHold(fix);
wth15.WaitTime = 0;
wth15.HoldTime = stim_time;
scene15 = create_scene(wth15, [fixation_point prob_stimulus(15,:)]);
% scene 015: delay15
wth015 = WaitThenHold(fix);
wth015.WaitTime = 0;
wth015.HoldTime = delay;
scene015 = create_scene(wth015,fixation_point);

% scene 16: sample16
wth16 = WaitThenHold(fix);
wth16.WaitTime = 0;
wth16.HoldTime = stim_time;
scene16 = create_scene(wth16, [fixation_point prob_stimulus(16,:)]);
% scene 016: delay16
wth016 = WaitThenHold(fix);
wth016.WaitTime = 0;
wth016.HoldTime = delay;
scene016 = create_scene(wth016,fixation_point);

% scene 17: sample17
wth17 = WaitThenHold(fix);
wth17.WaitTime = 0;
wth17.HoldTime = stim_time;
scene17 = create_scene(wth17, [fixation_point prob_stimulus(17,:)]);
% scene 017: delay17
wth017 = WaitThenHold(fix);
wth017.WaitTime = 0;
wth017.HoldTime = delay;
scene017 = create_scene(wth017,fixation_point);

% scene 18: sample18
wth18 = WaitThenHold(fix);
wth18.WaitTime = 0;
wth18.HoldTime = stim_time;
scene18 = create_scene(wth18, [fixation_point prob_stimulus(18,:)]);
% scene 018: delay18
wth018 = WaitThenHold(fix);
wth018.WaitTime = 0;
wth018.HoldTime = delay;
scene018 = create_scene(wth018,fixation_point);

% scene 19: sample19
wth19 = WaitThenHold(fix);
wth19.WaitTime = 0;
wth19.HoldTime = stim_time;
scene19 = create_scene(wth19, [fixation_point prob_stimulus(19,:)]);
% scene 019: delay19
wth019 = WaitThenHold(fix);
wth019.WaitTime = 0;
wth019.HoldTime = delay;
scene019 = create_scene(wth019,fixation_point);

% scene 20: sample20
wth20 = WaitThenHold(fix);
wth20.WaitTime = 0;
wth20.HoldTime = stim_time;
scene20 = create_scene(wth20, [fixation_point prob_stimulus(20,:)]);
% scene 020: delay20
wth020 = WaitThenHold(fix);
wth020.WaitTime = 0;
wth020.HoldTime = delay;
scene020 = create_scene(wth020,fixation_point);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task:
error_type = 0;
run_scene(scene0,fix_eventmaker);
if ~wth0.Success
    error_type = 1;
else
    run_scene(scene1,stim_eventmaker);
    if ~wth1.Success
        error_type = 1;
    else
        run_scene(scene01,delay_eventmaker);
        if ~wth01.Success
            error_type = 1;
        else
            run_scene(scene2,stim_eventmaker);
            if ~wth2.Success 
                error_type = 1; % Did not see two, only see one
            else
                run_scene(scene02,delay_eventmaker);     
                if ~wth02.Success
                    error_type = 2; % Already See 2
                else
                    run_scene(scene3,stim_eventmaker); 
                    if ~wth3.Success
                        error_type = 2; % Did not see 3, only see 1 and 2
                    else
                        run_scene(scene03,delay_eventmaker);     
                        if ~wth03.Success
                            error_type = 3; % Already see 3
                        else
                            run_scene(scene4,stim_eventmaker);
                            if ~wth4.Success
                                error_type = 3;
                            else
                                run_scene(scene04,delay_eventmaker);     
                                if ~wth04.Success
                                    error_type = 4;
                                else
                                    run_scene(scene5,stim_eventmaker);
                                    if ~wth5.Success
                                        error_type = 4;
                                    else
                                        %goodmonkey(reward+3,'eventmarker',100);
                                        run_scene(scene05,delay_eventmaker);     
                                        if ~wth05.Success
                                            error_type = 5;
                                        else
                                            run_scene(scene6,stim_eventmaker);
                                            if ~wth6.Success
                                                error_type = 5;
                                            else
                                                run_scene(scene06,delay_eventmaker);     
                                                if ~wth06.Success
                                                    error_type = 6;
                                                else
                                                    run_scene(scene7,stim_eventmaker);
                                                    if ~wth7.Success
                                                        error_type = 6;
                                                    else
                                                        run_scene(scene07,delay_eventmaker);     
                                                        if ~wth07.Success
                                                            error_type = 7;
                                                        else
                                                            run_scene(scene8,stim_eventmaker);
                                                            if ~wth8.Success
                                                                error_type = 7;
                                                            else
                                                                run_scene(scene08,delay_eventmaker);     
                                                                if ~wth08.Success
                                                                    error_type = 8;
                                                                else
                                                                    run_scene(scene9,stim_eventmaker);
                                                                    if ~wth9.Success
                                                                        error_type = 8;
                                                                    else
                                                                        run_scene(scene09,delay_eventmaker);     
                                                                        if ~wth09.Success
                                                                            error_type = 9;
                                                                        else
                                                                            run_scene(scene10,stim_eventmaker);
                                                                            if ~wth10.Success
                                                                                error_type = 9;
                                                                            else
                                                                                %goodmonkey(reward+5,'eventmarker',reward);
                                                                                %error_type = 0; % TASK completed
                                                                                run_scene(scene010,delay_eventmaker);
                                                                                if ~wth010.Success
                                                                                error_type = 9;
                                                                                else

run_scene(scene11,stim_eventmaker);
if ~wth11.Success
    error_type = 9;
else
    run_scene(scene011,delay_eventmaker);
    if ~wth011.Success
        error_type = 9;
    else
        run_scene(scene12,stim_eventmaker);
        if ~wth12.Success 
            error_type = 9; 
        else
            run_scene(scene012,delay_eventmaker);     
            if ~wth012.Success
                error_type = 9; % Already see twelve
            else
                run_scene(scene13,stim_eventmaker); 
                if ~wth13.Success
                    error_type = 9; % Did not see thirteen, only see eleven and twelve
                else
                    run_scene(scene013,delay_eventmaker);     
                    if ~wth013.Success
                        error_type = 9; % Already see thirteen
                    else
                        run_scene(scene14,stim_eventmaker);
                        if ~wth14.Success
                            error_type = 9;
                        else
                            run_scene(scene014,delay_eventmaker);     
                            if ~wth014.Success
                                error_type = 9;
                            else
                                run_scene(scene15,stim_eventmaker);
                                if ~wth15.Success
                                    error_type = 9;
                                else
                                    run_scene(scene015,delay_eventmaker);     
                                    if ~wth015.Success
                                        error_type = 9;
                                    else
                                        run_scene(scene16,stim_eventmaker);
                                        if ~wth16.Success
                                            error_type = 9;
                                        else
                                            run_scene(scene016,delay_eventmaker);     
                                            if ~wth016.Success
                                                error_type = 9;
                                            else
                                                run_scene(scene17,stim_eventmaker);
                                                if ~wth17.Success
                                                    error_type = 9;
                                                else
                                                    run_scene(scene017,delay_eventmaker);     
                                                    if ~wth017.Success
                                                        error_type = 9;
                                                    else
                                                        run_scene(scene18,stim_eventmaker);
                                                        if ~wth18.Success
                                                            error_type = 9;
                                                        else
                                                            run_scene(scene018,delay_eventmaker);     
                                                            if ~wth018.Success
                                                                error_type = 9;
                                                            else
                                                                run_scene(scene19,stim_eventmaker);
                                                                if ~wth19.Success
                                                                    error_type = 9;
                                                                else
                                                                    run_scene(scene019,delay_eventmaker);     
                                                                    if ~wth019.Success
                                                                        error_type = 9;
                                                                    else
                                                                        run_scene(scene20,stim_eventmaker);
                                                                        if ~wth20.Success
                                                                            error_type = 9;
                                                                        else
                                                                            %goodmonkey(reward+5,'eventmarker',100);
                                                                            run_scene(scene020,delay_eventmaker);
                                                                            if ~wth020.Success
                                                                                error_type = 9;
                                                                            else
                                                                                %goodmonkey(reward+5,'eventmarker',reward);
                                                                                goodmonkey(reward, 'juiceline',1, 'numreward',1, 'pausetime',200, 'eventmarker',reward_eventmaker)
                                                                                error_type = 0; % TASK completed
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
                            end
                        end
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % error
% % 1 fixation and see image 1
% % 2 saw image 2
% % 3 saw image 3
% % 4
% % 5
% % 6
% % 7
% % 8
% % 9 saw 9 images
% % 0 task completed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idle(0); % clear screen
trialerror(error_type);
if error_type == 0
    set_iti(50)
else
    set_iti(500)
end

errors = TrialRecord.TrialErrors;
errors_0 = errors(errors == 0);
if length(errors_0)>100
    escape_screen();
end

