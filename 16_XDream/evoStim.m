% evoStim.m — 10-image burst (each: ON 100 ms + OFF 100 ms)

% Optional: require eye input to be configured
% if ~ML_eyepresent, error('This task expects an eye signal or simulation mode.'); end

hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

% Markers (optional)
% 10 = Fix On, 21..30 = Img1..Img10, 40 = End
bhv_code(10,'Fix On', ...
         21,'Img1', 22,'Img2', 23,'Img3', 24,'Img4', 25,'Img5', ...
         26,'Img6', 27,'Img7', 28,'Img8', 29,'Img9', 30,'Img10', ...
         40,'End');

% TaskObject indices:
fix  = 1;
img1 = 2; img2 = 3; img3 = 4; img4 = 5; img5 = 6;
img6 = 7; img7 = 8; img8 = 9; img9 = 10; img10 = 11;
imgs = [img1 img2 img3 img4 img5 img6 img7 img8 img9 img10];

% Times (ms)
wait_for_fix = 5000;
fix_hold_pre = 300;     % hold fixation before the image train (optional)
on_ms  = 100;
off_ms = 100;

% Windows (deg) if using eye
fix_radius  = 2.0;
hold_radius = 2.5;

% --- Begin ---
error_type = 0;

% Show fixation and acquire
toggleobject(fix,'eventmarker',10);
if ML_eyepresent
    ontarget = eyejoytrack('acquirefix', fix, fix_radius, wait_for_fix);
    if ~ontarget, error_type = 4; end % no fixation
    if 0==error_type
        ontarget = eyejoytrack('holdfix', fix, hold_radius, fix_hold_pre);
        if ~ontarget, error_type = 3; end % broke fixation
    end
end

% Run the 10-image burst
if 0==error_type
    for k = 1:10
        toggleobject(imgs(k), 'eventmarker', 20+k); % 21..30
        idle(on_ms);
        toggleobject(imgs(k),'status','off');
        if k < 10
            idle(off_ms);
            if ML_eyepresent
                % keep fixation during off periods if desired
                ontarget = eyejoytrack('holdfix', fix, hold_radius, off_ms);
                if ~ontarget, error_type = 3; break; end
            end
        end
    end
end

% Clear screen
toggleobject([fix imgs], 'status','off');

% Simple outcome handling (optional)
if 0==error_type
    goodmonkey(100, 'eventmarker',50);
else
    idle(10);
end

trialerror(error_type);
eventmarker(40);   % 'End'
