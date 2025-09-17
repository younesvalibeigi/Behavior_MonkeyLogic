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

% TTL settings
ttl_obj = 12;                  % <-- TaskObject index for ttl(1); adjust if different
ttl_ms  = 10;      % 10 ms pulse (or set to round(1000/MLConfig.RefreshRate) for 1 frame)

% Windows (deg) if using eye
fix_radius  = 2.0;
hold_radius = 2.5;

% --- Begin ---
error_type = 0;

% Show fixation and acquire
toggleobject(fix,'eventmarker',10);
if ML_eyepresent
    ontarget = eyejoytrack('acquirefix', fix, fix_radius, wait_for_fix);
    if ~ontarget, error_type = 1; end % no fixation
    if 0==error_type
        ontarget = eyejoytrack('holdfix', fix, hold_radius, fix_hold_pre);
        if ~ontarget, error_type = 2; end % broke fixation
    end
end

% Run the 10-image burst
num_TTL = 0;
if 0==error_type
    for k = 1:10
        % Image ON + TTL ON at the same flip, with event code 21..30
        toggleobject([imgs(k) ttl_obj], 'eventmarker', 20+k);
        % keep track of number of images shown
        num_TTL = num_TTL +1;
        
        % Keep TTL high for ttl_ms, then drop it while keeping image ON
        idle(ttl_ms);
        toggleobject(ttl_obj, 'status', 'off');
        
        % Finish the remaining ON time so total ON = on_ms
        idle(on_ms - ttl_ms);
        
        % Image OFF
        toggleobject(imgs(k), 'status', 'off');

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

bhv_variable('num_TTL', num_TTL);
TrialRecord.User.num_TTL = num_TTL;

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
