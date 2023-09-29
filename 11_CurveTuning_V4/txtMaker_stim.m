% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4', 'TaskObject#5', 'TaskObject#6', 'TaskObject#7', 'TaskObject#8', 'TaskObject#9', 'TaskObject#10', 'TaskObject#11', 'TaskObject#12', 'TaskObject#13', 'TaskObject#14', 'TaskObject#15', 'TaskObject#16', 'TaskObject#17', 'TaskObject#18', 'TaskObject#19', 'TaskObject#20', 'TaskObject#21', 'TaskObject#22', 'TaskObject#23', 'TaskObject#24', 'TaskObject#25', 'TaskObject#26', 'TaskObject#27', 'TaskObject#28', 'TaskObject#29', 'TaskObject#30', 'TaskObject#31', 'TaskObject#32', 'TaskObject#33', 'TaskObject#34', 'TaskObject#35', 'TaskObject#36', 'TaskObject#37', 'TaskObject#38', 'TaskObject#39', 'TaskObject#40', 'TaskObject#41', 'TaskObject#42', 'TaskObject#43', 'TaskObject#44', 'TaskObject#45', 'TaskObject#46', 'TaskObject#47', 'TaskObject#48', 'TaskObject#49', 'TaskObject#50', 'TaskObject#51', 'TaskObject#52', 'TaskObject#53', 'TaskObject#54', 'TaskObject#55', 'TaskObject#56', 'TaskObject#57', 'TaskObject#58', 'TaskObject#59', 'TaskObject#60', 'TaskObject#61', 'TaskObject#62', 'TaskObject#63', 'TaskObject#64', 'TaskObject#65'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2.0 -2.0];
for i = 1:10
    data_row = {num2str(i), '1', '1', 'CurveTuning_V4', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    for j = ((i-1)*64 + 1):(i*64)
        data_row{end+1} = sprintf('pic(stim%03d.png,%.2f,%.2f)', j, rf(1), rf(2));
    end
    data_rows(i, :) = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'my_file.txt';
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
