% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2.5 -2.0];
pxperdeg = 36.039;
img_size = [8 8]*pxperdeg;
num_levels = 9;
for i = 1:num_levels
    block = 1;%mod(i,64)+1;
    data_row = {num2str(i), '1', num2str(block), 'stimulus_show1img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    data_row{end+1} = sprintf('pic(morph_linear%d.png,%.2f,%.2f,%.2f,%.2f)', i, rf(1), rf(2), img_size(1), img_size(2));
    
    data_rows(i, :) = data_row;
end
for i = num_levels+1:num_levels*2
    block = 1;%mod(i,64)+1;
    data_row = {num2str(i), '1', num2str(block), 'stimulus_show1img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    data_row{end+1} = sprintf('pic(morph_slerp%d.png,%.2f,%.2f,%.2f,%.2f)', i-num_levels, rf(1), rf(2), img_size(1), img_size(2));
    
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
filename = 'morph_1stim.txt';
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
