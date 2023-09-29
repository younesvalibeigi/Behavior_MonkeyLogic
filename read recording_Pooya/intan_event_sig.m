function intan_event_sig 

read_Intan_RHD2000_file %Giving info
frequency_parameters = evalin('base','frequency_parameters');

%% Read Monkey Logic file - BHV file
Files_ML = dir('*.bhv2');
BHV = mlread(Files_ML.name);
BHV_Name = sprintf('BHV_%s.mat',Files_ML.name);
save(BHV_Name,'BHV')

%% Timing File % changing file from time.dat to time.mat
fileinfo = dir('time.dat');
num_samples = fileinfo.bytes/4; % int32 = 4 bytes
fid = fopen('time.dat', 'r');
t = fread(fid, num_samples, 'int32');
fclose(fid);
t = t / frequency_parameters.amplifier_sample_rate; % sample rate from header file  (in second)
% move_to_base_workspace(t)
save('time.mat','t')
clear t

%% Behavioral Digital Events
DIN = {};
Files = dir('*board-DIN*.dat');
for i = 1:9
    FileName = Files(i).name;
    num_samples = fileinfo.bytes/2; % uint 16
    fid = fopen(FileName, 'r');
    DIN{i,1} = fread(fid, num_samples, 'uint16');
    fclose(fid);
end
% move_to_base_workspace(DIN)

%% Finding Syncronization point % sync DIN file
FsAnalog = 1000;
FsRatio = frequency_parameters.amplifier_sample_rate/FsAnalog;

% Extracting each trial start time
for i = 1:length([BHV.AbsoluteTrialStartTime])
    if i == 1
        StartTimeEachTrial(i) = 0;
    else
        StartTimeEachTrial(i) = floor(BHV(i).AbsoluteTrialStartTime*FsRatio); % sample
    end
end

% Find the first digital pulse
% for i = 1:length(DIN{9,1})
%     if DIN{9,1}(i,1) == 0
%         First_pulse = (i)-1;
%         break
%     end
% end
for i = 1:length(DIN{1,1})
    if (DIN{1,1}(i,1) == 1)&&(DIN{2,1}(i,1) == 0)&&(DIN{3,1}(i,1) == 0)&&(DIN{4,1}(i,1) == 1)&&(DIN{5,1}(i,1) == 0)&&(DIN{6,1}(i,1) == 0)&&(DIN{7,1}(i,1) == 0)&&(DIN{8,1}(i,1) == 0)
        First_pulse = (i);
        break
    end
end


% Cut the signal and creat the new 0 point
T_start_new = First_pulse - floor(BHV(1).BehavioralCodes.CodeTimes(1,1)*FsRatio);

for i = 1:9
    DIN_sync{i,1} = 100*(DIN{i,1}(T_start_new:end)); % Corrected
end
length_total_sync = length(DIN_sync{9,1});

% move_to_base_workspace(DIN_sync)
% move_to_base_workspace(length_total_sync)
save('length_total_sync', '-v7.3')
save('DIN_sync.mat','DIN_sync', '-v7.3')
clear DIN_sync
clear DIN

%% Signals % producing Sig1-32.mat  
Files = dir('*amp*.dat');
% for i =1:length(Files)
for i =1:32
    FileName = Files(i).name;
    num_samples = Files(i).bytes/2; % int16 = 2 bytes
    fid = fopen(FileName, 'r');
    SignalRaw{i,1} = (fread(fid, num_samples, 'int16'));
    fclose(fid);
    SignalRaw{i,1} = SignalRaw{i,1} * 0.195;  % convert to microvolts
    SignalRaw_sync{i,1} = SignalRaw{i,1}(T_start_new:end);
    data = (SignalRaw_sync{i,1})';
    fname = sprintf('Sig%d.mat',i);
    save(fname,'data');
    clear data
    clear SignalRaw{i,1}
    clear SignalRaw_sync{i,1}
end
% move_to_base_workspace(SignalRaw)

end


function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

end