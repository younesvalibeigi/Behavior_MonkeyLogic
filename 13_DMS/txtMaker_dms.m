% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-4.2 -0.5];
pxperdeg = 36.039;
img_size = [7 7]*pxperdeg;
loc_1 = [-6 0];
loc_2 = [6 0];
num_cond = 48;
for i = 1:num_cond
    if floor(i/(num_cond/2+1)) == 0
        block = 1; 
    else
        block = 1;
    end

    if i<=4
        level=0;
    elseif i<=8
        level=1;
    elseif i<=12
        level=2;
    elseif i<=16
        level=10;
    elseif i<=20
        level=14;
    elseif i<=24
        level=-1;
    elseif i<=28
        level=0;
    elseif i<=32
        level=1;
    elseif i<=36
        level=2;
    elseif i<=40
        level=10;
    elseif i<=44
        level=14;
    elseif i<=48
        level=-1;
    end

    if level==-1
        cir_stim = 'cir20';
        rad_stim = 'rad20';
    else
        cir_stim = ['cir' num2str(level)];
        rad_stim = ['rad' num2str(level)];
    end

    data_row = {num2str(i), '2', num2str(block), 'dms', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
    if  mod(i, 4) == 1
        sample = cir_stim; target = 'cir0'; distractor = 'rad0'; target_loc = loc_1; distractor_loc = loc_2;
        %target_loc = loc_2; distractor_loc = loc_1;
    elseif mod(i,4) ==  2
        sample = cir_stim; target = 'cir0'; distractor = 'rad0'; target_loc = loc_2; distractor_loc = loc_1;
        %target_loc = loc_1; distractor_loc = loc_2;
    elseif mod(i,4) == 3
        sample = rad_stim; target = 'rad0'; distractor = 'cir0'; target_loc = loc_1; distractor_loc = loc_2;
        %target_loc = loc_2; distractor_loc = loc_1;
    else
        sample = rad_stim; target = 'rad0'; distractor = 'cir0'; target_loc = loc_2; distractor_loc = loc_1;
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
filename = 'dms_younes4.txt';
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
