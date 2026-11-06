%% RHX Spike-Only Online Firing Rate + simple polling TCP server (R2024b compatible)
% - Connects to RHX (tcpclient) for command/wave/spike streams
% - Detects DIGITAL-IN-01 rising edges to mark trial start
% - Computes FR per trial (windowed around TTL)
% - Buffers FR matrix [selected channels x N], one column per finalized trial
% - tcpserver responds to "GET" from client, sends matrix, then clears FR

%% ==== FR TCP Server (modern tcpserver; single client) ====
%clear tcpserver tcpclient
clear cleanupObj frServer tcommand twave tspike   % clean shutdown after End_Task

%% ======= USER SETTINGS =======
ip_cmd   = '127.0.0.1';  port_cmd   = 5000;
ip_wave  = '127.0.0.1';  port_wave  = 5001;
ip_spike = '127.0.0.1';  port_spike = 5002;

digitalInLabel = 'DIGITAL-IN-01';
digitalBitIdx  = 0;

winStart = 0.090;     % s
winEnd   = 0.205; %0.200     % s
finalizeMargin = 0.010; % s

countID0 = true;      % include unitID==0

%doRecord = false;     % true=record, false=run
choice = questdlg('Do you want to record?', ...
    'Recording Option', ...
    'Yes','No','No');   % Default is 'No'

switch choice
    case 'Yes'
        doRecord = true;
        disp('Start recording!')
    case 'No'
        doRecord = false;
        disp('Continue without recording!')
    otherwise
        doRecord = false;  % if window closed without choice
        disp('Continue without recording!')

end


% Select channels (RHX uses zero-based channel numbers 0..31).
portLetters = {'A','B','C','D'};
chPerPort = 32;
answers = inputdlg( ...
    {'Port A channels (0-31):', 'Port B channels (0-31):', ...
     'Port C channels (0-31):', 'Port D channels (0-31):'}, ...
    'Select spike channels (blank = none)', [1 55], ...
    {'22', '', '', ''});
if isempty(answers), error('Channel selection cancelled.'); end

enabledChNames = {};
for p = 1:numel(portLetters)
    selected = parseChannels(answers{p}, chPerPort);
    for k = selected
        enabledChNames{end+1} = sprintf('%s-%03d', portLetters{p}, k); %#ok<SAGROW>
    end
end
NCH = numel(enabledChNames);
if NCH == 0, error('Select at least one channel.'); end
fprintf('Selected %d channels (FR rows in this order):\n', NCH);
for i = 1:NCH, fprintf('  Row %d: %s\n', i, enabledChNames{i}); end

fr_bind_ip   = "0.0.0.0";  % listen on all interfaces % 10.68.15.49
fr_bind_port = 6010;

printHeaderEveryNTrials = 10;

% ======= PSTH SETTINGS =======
makePSTH    = true;     % Plot one PSTH per selected channel
psthBin     = 0.005;    % 5 ms bins
psth_start  = -0.05;    % 50 ms before TTL
psth_end    = 0.250;    % 250 ms after TTL

%% ======= CONNECT RHX =======
fprintf('\n==== RHX Spike Rate Server (digital-triggered) ====\n');
fprintf('Command   : %s:%d\n', ip_cmd, port_cmd);
fprintf('Waveform  : %s:%d  (DIGITAL-IN only)\n', ip_wave, port_wave);
fprintf('Spike     : %s:%d\n', ip_spike, port_spike);
fprintf('Digital-in: %s (bit %d)\n', digitalInLabel, digitalBitIdx);
fprintf('Window    : [%.3f, %.3f] s (finalize +%.3f)\n', winStart, winEnd, finalizeMargin);

tcommand = tcpclient(ip_cmd,   port_cmd);
twave    = tcpclient(ip_wave,  port_wave);
tspike   = tcpclient(ip_spike, port_spike);

cleanupObj = onCleanup(@() teardown(tcommand, twave, tspike)); %#ok<NASGU>

sendCmd(tcommand, 'execute clearalldataoutputs');
Fs = getSampleRateHz(tcommand);
dt = 1/Fs;
fprintf('SampleRate: %.1f Hz\n', Fs);

sendCmd(tcommand, sprintf('set %s.tcpdataoutputenabled true', digitalInLabel));

for i = 1:numel(enabledChNames)
    chLower = lower(enabledChNames{i});
    sendCmd(tcommand, sprintf('set %s.tcpdataoutputenabled false',     chLower));
    sendCmd(tcommand, sprintf('set %s.tcpdataoutputenabledlow false',  chLower));
    sendCmd(tcommand, sprintf('set %s.tcpdataoutputenabledhigh false', chLower));
    sendCmd(tcommand, sprintf('set %s.tcpdataoutputenabledspike true', chLower));
end
pause(0.5);

%% ======= CONSTANTS =======
framesPerBlock      = 128;
digInWordPresent    = 1;
bytesPerFrame       = 4 + 2*digInWordPresent;
bytesPerBlock       = 4 + framesPerBlock*bytesPerFrame;
blocksPerRead       = 20;
waveBytesN          = blocksPerRead * bytesPerBlock;

bytesPerSpikeChunk  = 14;
SPIKE_MAGIC         = uint32(hex2dec('3ae2710f'));
WAVE_MAGIC          = uint32(hex2dec('2ef07a08'));

%% ======= RHX RUN =======
if doRecord
    sendCmd(tcommand, 'set runmode record');
else
    sendCmd(tcommand, 'set runmode run');
end
fprintf('Running… Press Ctrl-C to stop.\n\n');

%% ======= FR SERVER (tcpserver, R2024b safe) =======
% try, clear frServer; catch, end
% frServer = tcpserver(fr_bind_ip, fr_bind_port, "Timeout", 0.01);
% if isprop(frServer,"Port")
%     fprintf('FR server listening on port %d (send "GET_FR\\n")\n', frServer.Port);
% elseif isprop(frServer,"ServerPort")
%     fprintf('FR server listening on port %d (send "GET_FR\\n")\n', frServer.ServerPort);
% else
%     fprintf('FR server listening (port property unavailable in this MATLAB)\n');
% end
% 
% cmdBuf = uint8(zeros(0,1));   % explicit empty column vector % buffer for incoming commands
try, clear frServer; catch, end
frServer = tcpserver(fr_bind_ip, fr_bind_port, "Timeout", 5);
configureTerminator(frServer, "LF");   % match client's CRLF
disp("[FR server] Listening on port " + fr_bind_port);
%% ===== PSTH plotting state =====
psth_rel = cell(NCH,1);    % Relative spike times per selected channel since last GET
if makePSTH
    psthFig = figure('Name','Selected Channel PSTHs','NumberTitle','off');
    nPlotCols = min(4, NCH);
    nPlotRows = ceil(NCH/nPlotCols);
    psthLayout = tiledlayout(psthFig, nPlotRows, nPlotCols, ...
        'TileSpacing','compact','Padding','compact');
    psthAx = gobjects(NCH,1);
    for i = 1:NCH
        psthAx(i) = nexttile(psthLayout);
        hold(psthAx(i),'on'); box(psthAx(i),'on');
        xline(psthAx(i), 0, ':', 'TTL');
        xline(psthAx(i), winStart, ':');
        xline(psthAx(i), winEnd, ':');
        xlim(psthAx(i), [psth_start, psth_end]);
        xlabel(psthAx(i), 'Time from TTL (s)');
        ylabel(psthAx(i), 'Firing rate (spikes/s)');
        title(psthAx(i), sprintf('%s (FR row %d)', enabledChNames{i}, i));
    end
    psthCmap     = turbo(50);
    psthCurveIdx = 0;
end

%% ======= STATE =======
spikeBuf = containers.Map('KeyType','char','ValueType','any');
for i = 1:numel(enabledChNames), spikeBuf(enabledChNames{i}) = []; end

FR = zeros(NCH,0);

lastWaveTs  = -Inf;
lastDigState = false;

pendingTrials = struct('t0', {}, 't1', {}, 't2', {});
trialCount = 0;
printHeader();


%% ======= MAIN LOOP =======
while true
    % ----- 1) SPIKES -----
    nB = tspike.BytesAvailable;
    if nB >= bytesPerSpikeChunk && mod(nB, bytesPerSpikeChunk)==0
        raw = read(tspike, nB);
        idx = 1;
        nChunks = nB / bytesPerSpikeChunk;
        for c = 1:nChunks
            [magic, idx]   = read_u32(raw, idx);
            if magic ~= SPIKE_MAGIC, error('Bad SPIKE magic'); end
            [nm, idx]      = read_char5(raw, idx);
            [ts_u32, idx]  = read_u32(raw, idx);
            [unitId, idx]  = read_u8(raw, idx);
            if (~countID0) && unitId==0, continue; end
            ts_sec = double(ts_u32) * dt;
            if isKey(spikeBuf,nm), spikeBuf(nm) = [spikeBuf(nm), ts_sec]; end
        end
        pruneBefore = lastWaveTs - 2.0;
        ks = keys(spikeBuf);
        for i = 1:numel(ks)
            v = spikeBuf(ks{i});
            if ~isempty(v)
                spikeBuf(ks{i}) = v(v >= pruneBefore);
            end
        end
    end

    % ----- 2) DIGITAL-IN -----
    if twave.BytesAvailable >= waveBytesN
        raw = read(twave, waveBytesN);
        idx = 1;
        for b = 1:blocksPerRead
            [magic, idx] = read_u32(raw, idx);
            if magic ~= WAVE_MAGIC, fprintf(2,'Wave magic mismatch\n'); end
            for f = 1:framesPerBlock
                [ts_i32, idx] = read_i32(raw, idx);
                t_sec = double(ts_i32) * dt;
                lastWaveTs = t_sec;
                [digWord, idx] = read_u16(raw, idx);
                digState = bitand(digWord,uint16(2^digitalBitIdx))>0;
                if (~lastDigState)&&digState
                    trialCount=trialCount+1;
                    t0 = t_sec;
                    pendingTrials(end+1).t0 = t0;    %#ok<SAGROW>
                    pendingTrials(end  ).t1 = t0+winStart; 
                    pendingTrials(end  ).t2 = t0+winEnd;
                end
                lastDigState = digState;
            end
        end
    end

    % ----- 3) FINALIZE TRIALS -----
    if ~isempty(pendingTrials)
        % When plotting, wait for the entire PSTH window before collecting spikes.
        % Otherwise retain the original firing-rate finalization time.
        if makePSTH
            ready = arrayfun(@(q) lastWaveTs >= ...
                (max(q.t2, q.t0+psth_end)+finalizeMargin), pendingTrials);
        else
            ready = arrayfun(@(q) lastWaveTs >= ...
                (q.t2+finalizeMargin), pendingTrials);
        end
        if any(ready)
            for r = find(ready)
                q = pendingTrials(r);
                t0 = q.t0; t1 = q.t1; t2 = q.t2; dur = max(0,t2-t1);
                fr_col = zeros(NCH,1);
                if dur>0
                    for i = 1:NCH
                        nm = enabledChNames{i};
                        sp = spikeBuf(nm);
                        fr_col(i) = sum(sp>=t1 & sp<t2)/dur;
                        % Collect PSTH spikes for every selected channel.
                        if makePSTH
                            rel = sp(sp >= t0+psth_start & sp < t0+psth_end) - t0;
                            psth_rel{i} = [psth_rel{i}, rel]; %#ok<AGROW>
                        end
                    end
                end
                FR = [FR, fr_col]; %#ok<AGROW>
               
                fprintf('%5d | %11.3f | %9.3f | %-25s | [%d %d]\n', ...
                            trialCount, t1, t2, mat2str(fr_col', 3), size(FR,1), size(FR,2));

            end
            pendingTrials = pendingTrials(~ready);
        end
    end

    % ----- 4) FR SERVER POLLING (robust) -----
    % % try
    %     if frServer.NumBytesAvailable > 0
    %         bytes = read(frServer, frServer.NumBytesAvailable, "uint8");
    %         bytes = uint8(bytes(:));                  % ← make it a column
    %         cmdBuf = [cmdBuf; bytes];  %#ok<AGROW>    % now both are columns
    %     end
    % 
    %     % Process all complete lines present. We treat either LF (10) or CR (13) as terminators.
    %     % This handles \n, \r\n, or \r, and also multiple lines in one read.
    %     while true
    %         % Find first occurrence of either LF or CR as a line terminator
    %         nl = find(cmdBuf==10 | cmdBuf==13, 1, 'first'); % 10=\n, 13=\r
    %         if isempty(nl), break; end
    % 
    %         rawLine = cmdBuf(1:nl-1);        % bytes before terminator
    %         termByte = cmdBuf(nl);           % the terminator we found
    %         cmdBuf = cmdBuf(nl+1:end);       % drop that line + terminator
    % 
    %         % If this was part of a CRLF pair, and the next byte is the other terminator, drop it too.
    %         if ~isempty(cmdBuf)
    %             if (termByte==13 && cmdBuf(1)==10) || (termByte==10 && cmdBuf(1)==13)
    %                 cmdBuf = cmdBuf(2:end);
    %             end
    %         end
    % 
    %         % Convert to text and strip any stray CR/LF and NULs at ends
    %         line = char(rawLine).';
    %         % Hard trim: remove spaces, tabs, CR, LF, and NUL at both ends
    %         line = regexprep(line, '^[\s\0\r\n]+|[\s\0\r\n]+$', '');
    % 
    %         % Debug: show exactly what we received (comment out once confirmed)
    %         fprintf('[FR server] Received line: "%s" | hex:%s\n', ...
    %             line, sprintf(' %02X', uint8(line)));
    % 
    %         if strcmpi(line, 'GET_FR')
    %             %disp('-----ss------')
    %             fr_snapshot = FR;
    %             FR = zeros(NCH,0);
    %             [rows,cols] = size(fr_snapshot);
    %             fprintf('[FR server] GET_FR -> replying with %dx%d\n', rows, cols);
    %             write(frServer,uint32(rows),"uint32");
    %             write(frServer,uint32(cols),"uint32");
    %             if rows*cols > 0
    %                 write(frServer,fr_snapshot(:),"double");
    %             end
    %         else
    %             fprintf('[FR server] Unknown command "%s" (ignored)\n', line);
    %         end
    %     end
    % % catch ME
    % %     fprintf(2,'[FR server] Error: %s\n', ME.message);
    % % end
    if frServer.Connected && frServer.NumBytesAvailable > 0
        req = strtrim(readline(frServer));  % read the 'GET' line
        if strcmpi(req, "GET")
            % caluclate the number of rows and columns
            [rows,cols] = size(FR);

            % 1) send header: [rows, cols] as uint32 (8 bytes)
            hdr = uint32([rows, cols]);
            write(frServer, typecast(hdr, 'uint8'));

            % 2) send payload: matrix as double, column-major (unchanged)
            write(frServer, typecast(FR(:), 'uint8'));
            fprintf("[%s] Sent %dx%d matrix. min=%.3f  max=%.3f  mean=%.3f\n", ...
                        datestr(now,'HH:MM:SS'), rows, cols, min(FR(:)), max(FR(:)), mean(FR(:)));
            % ---- Plot one PSTH panel per selected channel (trials since GET) ----
            if makePSTH && cols>0 && isgraphics(psthFig)
                edges = psth_start:psthBin:psth_end;
                binCenters = edges(1:end-1) + diff(edges)/2;
                psthCurveIdx = psthCurveIdx + 1;
                ci = min(psthCurveIdx, size(psthCmap,1));
                thisColor = psthCmap(ci,:);
                for i = 1:NCH
                    counts = histcounts(psth_rel{i}, edges);
                    rate = counts ./ (cols * psthBin);
                    plot(psthAx(i), binCenters, rate, '-', ...
                        'Color', thisColor, ...
                        'DisplayName', sprintf('Batch %d (n=%d)', psthCurveIdx, cols));
                end
                drawnow limitrate;
            end
            psth_rel = cell(NCH,1); % Clear PSTH data for next GET batch
            % ---- Redefine FR to start from scratch.
            FR = zeros(NCH,0);

        elseif strcmpi(req, "End_Task")   
            sendCmd(tcommand, 'set runmode stop');           % stop RHX
            fprintf('[Server] End_Task received: stopping.\n');
            break;   % exits the while true loop
        else
            writeline(frServer, "ERR unknown command");
        end
    end


    pause(0.005);
%% Ending While
end
%% ======= HELPERS =======
function printHeader()
fprintf('Trial | winStart(s) | winEnd(s) | FR Added                  | FR Size\n');
fprintf('----------------------------------------------------------------------\n');
end
%function sendCmd(t,s), write(t,uint8(s)); end
function sendCmd(t,s), write(t,uint8([s ';'])); end
function fs=getSampleRateHz(t)
write(t,uint8('get sampleratehertz'));
s=readReplyLine(t,2.0);
key='Return: SampleRateHertz ';
assert(startsWith(s,key));
fs=str2double(strrep(s,key,''));
end
function s=readReplyLine(t,timeout_s)
tic;
while t.BytesAvailable==0
    if toc>timeout_s, error('Timeout'); end
    pause(0.01);
end
s=char(read(t));
end
function [v,i]=read_u32(a,i), v=typecast(uint8(a(i:i+3)),'uint32'); i=i+4; end
function [v,i]=read_i32(a,i), v=typecast(uint8(a(i:i+3)),'int32'); i=i+4; end
function [v,i]=read_u16(a,i), v=typecast(uint8(a(i:i+1)),'uint16'); i=i+2; end
function [v,i]=read_u8(a,i),  v=a(i); i=i+1; end
function [s,i]=read_char5(a,i), s=native2unicode(a(i:i+4)); i=i+5; end
function teardown(tcommand,twave,tspike)
try, write(tcommand,uint8('set runmode stop')); end
try, read(tspike); end
try, read(twave); end
fprintf('\n[Cleanup] RHX stopped and sockets cleaned up.\n');
end

% Helper: safe write
function ok = safeWrite(s, data, dtype)
    ok = false;
    if ~isvalid(s) || ~s.Connected, return; end
    try
        if nargin < 3
            writeline(s, data);    % text path
        else
            write(s, data, dtype); % binary path
        end
        ok = true;
    catch ME
        warning("[FR server] write failed: %s", ME.message);
    end
end

% function channels = parseChannels(txt, chPerPort)
% % Accept comma/space-separated channels and inclusive ranges, e.g. 4,5,10:15.
% channels = [];
% txt = strtrim(txt);
% if isempty(txt), return; end
% tokens = regexp(txt, '[,\s]+', 'split');
% for j = 1:numel(tokens)
%     token = tokens{j};
%     parts = regexp(token, '^(\d+)(?:[:-](\d+))?$', 'tokens', 'once');
%     if isempty(parts)
%         error('Invalid channel entry "%s". Use 0..31, e.g. 4,5,10:15.', token);
%     end
%     first = str2double(parts{1});
%     if numel(parts) == 2 && ~isempty(parts{2})
%         last = str2double(parts{2});
%     else
%         last = first;
%     end
%     if first > last || first < 0 || last >= chPerPort
%         error('Channel/range "%s" is outside 0..%d or reversed.', token, chPerPort-1);
%     end
%     channels = [channels, first:last]; %#ok<AGROW>
% end
% channels = unique(channels, 'stable');
% end

function channels = parseChannels(txt, chPerPort)
channels = [];
txt = strtrim(txt);
if isempty(txt), return; end
% Split by commas or spaces
tokens = regexp(txt, '[,\s]+', 'split');
for j = 1:numel(tokens)
    token = strtrim(tokens{j});
    % Check whether this is a range
    if contains(token, '-') || contains(token, ':')
        bounds = regexp(token, '[:-]', 'split');
        if numel(bounds) ~= 2
            error('Invalid channel range: %s', token);
        end
        first = str2double(bounds{1});
        last  = str2double(bounds{2});
    else
        first = str2double(token);
        last  = first;
    end
    if isnan(first) || isnan(last) || ...
            first < 0 || last >= chPerPort || first > last || ...
            mod(first,1) ~= 0 || mod(last,1) ~= 0
        error('Invalid channel selection: %s', token);
    end
    channels = [channels, first:last];
end
channels = unique(channels, 'stable');
end