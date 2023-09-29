function displayStim()
   set_bgcolor([127 127 127]);
    for i=0:5:255
        box3 = BoxGraphic(null_);
        box3.List = { [i i i], [i i i], [1 1], [0 0], 8, 0 };
        tc3 = TimeCounter(null_);  % Note that TimeCounter takes NullTracker, unlike Method 2
        tc3.Duration = 100;%10000;
        con3 = Concurrent(tc3);    % Concurrent combines two adapter chains, but its behavior
        con3.add(box3);            % depends on the first chain only, which is tc3 here.
                                   % See the manual for details.
        scene3 = create_scene(con3);  % Concurrent - TimeCounter - NullTracker (chain 1)
                                   %          +-- BoxGraphic - NullTracker (chain 2)
        run_scene(scene3,30);

    end
    % Run the scenes
    % run_scene(scene1,10);
    % run_scene(scene2,20);
    idle(50,[],40);  % clear the screens

end