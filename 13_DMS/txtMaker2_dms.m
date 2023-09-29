% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-2 -2];
pxperdeg = 36.039;
img_size = [5 5]*pxperdeg;
loc_1 = [-6 0];
loc_2 = [6 0];
num_cond = 8;
for i = 1:num_cond
    if floor(i/(num_cond/2+1)) == 0
        block = 1; 
    else
        block = 1;%2;
    end
    data_row = {num2str(i), '1', num2str(block), 'dms', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    
    if  mod(i, 4) == 1
        sample = 'cir'; target = 'cir'; distractor = 'rad'; target_loc = loc_1; distractor_loc = loc_2;
        %target_loc = loc_2; distractor_loc = loc_1;
    elseif mod(i,4) ==  2
        sample = 'cir'; target = 'cir'; distractor = 'rad'; target_loc = loc_2; distractor_loc = loc_1;
        %target_loc = loc_1; distractor_loc = loc_2;
    elseif mod(i,4) == 3
        sample = 'rad'; target = 'rad'; distractor = 'cir'; target_loc = loc_1; distractor_loc = loc_2;
        %target_loc = loc_2; distractor_loc = loc_1;
    else
        sample = 'rad'; target = 'rad'; distractor = 'cir'; target_loc = loc_2; distractor_loc = loc_1;
        %target_loc = loc_1; distractor_loc = loc_2;
    end
    

    data_row{end+1} = sprintf('pic(%s.png,%.2f,%.2f,%.2f,%.2f)', sample, rf(1), rf(2), img_size(1), img_size(2));
    
    data_row{end+1} = sprintf('pic(%s.png,%.2f,%.2f,%.2f,%.2f)', target, target_loc(1), target_loc(2), img_size(1), img_size(2));
    data_row{end+1} = sprintf('pic(%s.png,%.2f,%.2f,%.2f,%.2f)', distractor, distractor_loc(1), distractor_loc(2), img_size(1), img_size(2));

    
    data_rows(i, :) = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
filename = 'dms_younes2.txt';
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
