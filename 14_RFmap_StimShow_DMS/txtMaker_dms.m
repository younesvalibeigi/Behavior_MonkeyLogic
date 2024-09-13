% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-7 -1];
pxperdeg = 36.039;
img_size = [10 10]*pxperdeg;
loc_1 = [-10 0];%[-6 0];
loc_2 = [10 0];%[6 0];
num_levels = 6*2;
num_cond = num_levels*4;%48;
freq = 2;

for i = 1:num_cond
    block = 1;
    level = floor((i-1)/4);
    %if i<25
    %    block = 1; 
    %else
    %    block = 1;
    %end
    levels = [0 6 14 28 49 85];
    blocks = {'1 2 3 4 5 6 7', '2 3 4 5 6 7', '3 4 5 6 7', '4 5 6 7', '5 6 7', '6 7'};
    if i<=1*4
        level=levels(1);
        block = blocks{1};
    elseif i<=2*4
        level=levels(2);
        block = blocks{2};
    elseif i<=3*4
        level=levels(3);
        block = blocks{3};
    elseif i<=4*4
        level=levels(4);
        block = blocks{4};
    elseif i<=5*4
        level=levels(5);
        block = blocks{5};
    elseif i<=6*4
        level=levels(6);
        block = blocks{6};
    elseif i<=7*4
        level=levels(1);
        block = blocks{1};
    elseif i<=8*4
        level=levels(2);
        block = blocks{2};
    elseif i<=9*4
        level=levels(3);
        block = blocks{3};
    elseif i<=10*4
        level=levels(4);
        block = blocks{4};
    elseif i<=11*4
        level=levels(5);
        block = blocks{5};
    elseif i<=12*4
        level=levels(6);
        block = blocks{6};
    end

    if level==-1
        cir_stim = 'empty';
        rad_stim = 'empty';
    else
        cir_stim = ['cir' num2str(level)];
        rad_stim = ['rad' num2str(level)];
    end

    data_row = {num2str(i), num2str(freq), block, 'dms', sprintf('fix(%.2f,%.2f)',fix(1), fix(2))};
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
filename = 'dms0.txt';
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
