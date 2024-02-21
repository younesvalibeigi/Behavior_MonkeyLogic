N = 10;
% stim_rf_seq = [];
% for i=1:10 %10 redundancy
%     num_b = 1:100; num_w = 101:200;
%     num_b = num_b(randperm(length(num_b))); num_w = num_w(randperm(length(num_w)));
%     for jj = 1:100
%         stim_rf_seq = [stim_rf_seq num_b(jj) num_w(jj)];
%     end
% end
% % Define the file name
% filename = ['stim_rf_seq_' num2str(N) 'X' num2str(N) '_BW.txt'];
% % Open the file for writing
% fileID = fopen(filename, 'w');
% % Check if the file was opened successfully
% if fileID == -1
%     error('Could not open file for writing');
% end
% % Write the array to the file
% fprintf(fileID, '%d\n', stim_rf_seq);
% % Close the file
% fclose(fileID);

% read teh file and put it in the array
% Define the file name
filename = ['stim_rf_seq_' num2str(N) 'X' num2str(N) '_BW.txt'];
% Open the file for reading
fileID = fopen(filename, 'r');
% Check if the file was opened successfully
if fileID == -1
    error('Could not open file for reading');
end
% Read the array from the file
stim_rf_seq = fscanf(fileID, '%d');
% Close the file
fclose(fileID);


% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6', 'TaskObject#7', 'TaskObject#8', 'TaskObject#9', 'TaskObject#10', 'TaskObject#11'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-3.0 -3.0];
pxperdeg = 36.039;
img_size = [7 7]*pxperdeg;
for i = 1:N*N*2
    block=1;
    frequency = 1;
    data_row = {num2str(i), num2str(frequency), num2str(block), 'stimulus_show10img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    for j = ((i-1)*10 + 1):(i*10)
        data_row{end+1} = sprintf('pic(rf_%02d.png,%.2f,%.2f,%.2f,%.2f)', stim_rf_seq(j), rf(1), rf(2), img_size(1), img_size(2));
    end
   

    data_rows(i, :) = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'rf_mapping_10X10_blackWhite_10img.txt';
fid = fopen(filename, 'wt');
fprintf(fid, '%s\t', rows{1,1:end-1});
fprintf(fid, '%s\n', rows{1,end});
for i = 2:size(rows, 1)
    fprintf(fid, '%s\t', rows{i,1:end-1});
    fprintf(fid, '%s\n', rows{i,end});
end
fclose(fid);

% Display the path to the file
fprintf('The file was saved as %s.\n', fullfile(pwd, filename));
