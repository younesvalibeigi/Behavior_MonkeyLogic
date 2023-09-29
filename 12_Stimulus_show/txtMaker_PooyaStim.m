% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2 -2];
pxperdeg = 36.039;
img_size = [4 4]*pxperdeg;
for i = 1:29
    if floor(i/14) == 0
        block = 1; 
    else
        block = 2;
    end
    data_row = {num2str(i), '1', num2str(block), 'stimulus_show5img', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    for j = ((i-1)*5 + 1):(i*5)
        data_row{end+1} = sprintf('pic(%d.png,%.2f,%.2f,%.2f,%.2f)', j, rf(1), rf(2), img_size(1), img_size(2));
    end
    data_rows(i, :) = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'Pooya_5stim.txt';
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
