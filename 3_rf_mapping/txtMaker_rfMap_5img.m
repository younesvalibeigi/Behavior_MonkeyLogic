% stim_rf_seq = [];
% for i=1:4
%     num = 1:36;
%     num = Shuffle(num);
%     stim_rf_seq = [stim_rf_seq num];
% end
% % Define the file name
% filename = 'stim_rf_seq.txt';
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
filename = 'stim_rf_seq.txt';
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
% add one 6 times to the end so the array has 150 size
for i=1:1
   stim_rf_seq(end+1) = 1;
end


% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2 -2];
pxperdeg = 36.039;
img_size = [12 12]*pxperdeg;
for i = 1:29
    block=1;
    frequency = 1;
    data_row = {num2str(i), num2str(frequency), num2str(block), 'stimulus_show5img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    for j = ((i-1)*5 + 1):(i*5)
        data_row{end+1} = sprintf('pic(rf_%02d.png,%.2f,%.2f,%.2f,%.2f)', stim_rf_seq(j), rf(1), rf(2), img_size(1), img_size(2));
    end
   

    data_rows(i, :) = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'rf_mapping_6X6_grating_5img.txt';
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
