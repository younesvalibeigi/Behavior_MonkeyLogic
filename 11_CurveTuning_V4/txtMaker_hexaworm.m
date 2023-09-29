% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6', 'TaskObject#7', 'TaskObject#8', 'TaskObject#9', 'TaskObject#10', 'TaskObject#11'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2 -2];
radius = 1.8;
pxperdeg = 36.039;
img_size = [radius radius]*2*pxperdeg;
%252
for i = 1:26
    data_row = {num2str(i), '1', '1', 'CurveTuning_V4', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    if i==26
        perm = randperm(250);
        last_row_num = [251 252]; last_row_num = [last_row_num perm(1:8)];
        for j = 1:10
        data_row{end+1} = sprintf('pic(hexaworm%03d.png,%.2f,%.2f,%.2f,%.2f)', last_row_num(j), rf(1), rf(2), img_size(1), img_size(2));
        end
        data_rows(i, :) = data_row;
    else
        for j = ((i-1)*10 + 1):(i*10)
            data_row{end+1} = sprintf('pic(hexaworm%03d.png,%.2f,%.2f,%.2f,%.2f)', j, rf(1), rf(2), img_size(1), img_size(2));
        end
        data_rows(i, :) = data_row;
    end
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'hexaworm.txt';
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
