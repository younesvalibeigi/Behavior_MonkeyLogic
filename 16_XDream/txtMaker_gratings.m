% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', ...
    'TaskObject#6', 'TaskObject#7', 'TaskObject#8', 'TaskObject#9', 'TaskObject#10', 'TaskObject#11'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-8 -2];
pxperdeg = 36.039;
img_size = [10 10]*pxperdeg;

% Folder
folder = 'gratings';
% Get list of PNG files
files = dir(fullfile(folder, '*.png'));
% Put names into a cell array with full paths
NAMES = fullfile({files.folder}, {files.name})';

nCond = length(NAMES)/10;
for i = 1:nCond
    block = 1;%mod(i,64)+1;
    data_row = {num2str(i), '1', num2str(block), 'stimulus_show10img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    for j = 1:10
        imgfile = NAMES{(i-1)*10 + j}; % pick 10 sequential images
        data_row{end+1} = sprintf('pic(%s,%.2f,%.2f,%.2f,%.2f)', imgfile, rf(1), rf(2), img_size(1), img_size(2));
    end
    
    data_rows(i, :) = data_row;
end
% for i = 3:4
%     block = 1;%mod(i,64)+1;
%     data_row = {num2str(i), '1', num2str(block), 'stimulus_show1img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
% 
%     data_row{end+1} = sprintf('pic(rad0.png,%.2f,%.2f,%.2f,%.2f)', rf(1), rf(2), img_size(1), img_size(2));
% 
%     data_rows(i, :) = data_row;
% end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'gratings_10stim.txt';
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
