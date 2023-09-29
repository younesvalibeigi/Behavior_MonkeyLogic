hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% How to draw a graphic object

% % Method 1: using a TaskObject
% %reposition_object(1,[-2 2]);   % TaskObject#1
% rescale_object(1,6);           % TaskObject#1
% %rotate_object(1,30);           % TaskObject#1
% set_bgcolor([127 127 127]);
% tc1 = TimeCounter(null_);
% tc1.Duration = 10^4; % 10;  % TaskObject#1
% 
% % Method 2: using a graphic adapter
% box2 = BoxGraphic(null_);
% % box2.EdgeColor = [1 1 1];
% % box2.FaceColor = [1 1 1];
% % box2.Size = [1 1];
% % box2.Position = [2 2];
% % box2.Scale = 2;
% % box2.Angle = 45;
% box2.List = { [1 1 1], [1 1 1], [1 1], [2 2], 2, 45 };  % Set all properties in one line via the List property
% tc2 = TimeCounter(box2);
% tc2.Duration = 1000;
% scene2 = create_scene(tc2);  % TimeCounter - BoxGraphic - NullTracker (a single chain)
% 
% % Method 3: using a graphic adapter but in a separate chain
% box3 = BoxGraphic(null_);
% box3.List = { [1 1 1], [1 1 1], [1 1], [2 -2], 2, 60 };
% tc3 = TimeCounter(null_);  % Note that TimeCounter takes NullTracker, unlike Method 2
% tc3.Duration = 1000;
% con3 = Concurrent(tc3);    % Concurrent combines two adapter chains, but its behavior
% con3.add(box3);            % depends on the first chain only, which is tc3 here.
%                            % See the manual for details.
% scene3 = create_scene(con3);  % Concurrent - TimeCounter - NullTracker (chain 1)
%                               %          +-- BoxGraphic - NullTracker (chain 2)
% s
% scene1 = create_scene(tc1,1)
% 
% 
% % for i=0:5:255                              
% %     rescale_object(1,6); tc1 = TimeCounter(null_); tc1.Duration = 10^4; % 10s
% %     scene1 = create_scene(tc1,1);
% %     run_scene(scene1,10*(i+1))
% % end
set_bgcolor([127 127 127]);
j=250;
cc = 0;
counter=0;
for i=0:5:255
    box3 = BoxGraphic(null_);
    box3.List = { [i i i], [i i i], [1 1], [0 0], 18, 0 };
    i
    %box4 = BoxGraphic(null_);
%     ii=i/2;
%     if cc==0
%         box3.List = { [ii ii ii], [ii ii ii], [1 1], [0 0], 16, 0 };
%         cc=1;
%         ii
%     else
%         box3.List = { [j j j], [j j j], [1 1], [0 0], 16, 0 };
%         cc=0;
%         j
%         j=j-10;
%     end
    
    tc3 = TimeCounter(null_);  % Note that TimeCounter takes NullTracker, unlike Method 2
    tc3.Duration = 10000;
    con3 = Concurrent(tc3);    % Concurrent combines two adapter chains, but its behavior
    con3.add(box3);            % depends on the first chain only, which is tc3 here.
%     con3.add(box4);                           % See the manual for details.
    scene3 = create_scene(con3);  % Concurrent - TimeCounter - NullTracker (chain 1)
                               %          +-- BoxGraphic - NullTracker (chain 2)
    run_scene(scene3,30);
    
    box4 = BoxGraphic(null_);
    box4.List = { [0 0 255], [0 0 255], [1 1], [0 0], 16, 0 };
    tc4 = TimeCounter(null_);
    tc4.Duration = 1000;
    con4 = Concurrent(tc4);    % Concurrent combines two adapter chains, but its behavior
    con4.add(box4); 
    scene4 = create_scene(con4);
    run_scene(scene4,30);


    counter=counter+1;
end
%counter
% Run the scenes
% run_scene(scene1,10);
% run_scene(scene2,20);
idle(50,[],40);  % clear the screens
