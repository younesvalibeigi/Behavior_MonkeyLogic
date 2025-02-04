% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4'};

% Define the data rows
data_rows = cell(10, length(header_row));
fix = [0 0];
rf = [-9 -4];
pxperdeg = 36.039;
img_size = [10 10]*pxperdeg;
target_im_size = [10 10]*pxperdeg;
loc_1 = [-10 0];%[-6 0];
loc_2 = [10 0];%[6 0];

%levels = [0 6 14 28 49 85]; %Used before sept 16, 2024
%levels = [0 6 20 37 49 90];%Used after sept 16, 2024
%levels = [0 6 20 37 49 90 101];%Used after Nov 6, 2024 ONLY TRIED ONE DAY
%AND NOT GOOD
levels = [0 6 20 37 49 90];

num_levels = length(levels)*2;
size_set = num_levels*2;
num_set = 3;
num_cond = size_set*num_set;%48;
freq = 2;

for i = 1:num_cond
    i_fullSet = floor((i-1)/size_set);
    block = 1;
    level = floor((i-1)/4);
    %if i<25
    %    block = 1; 
    %else
    %    block = 1;
    %end
    
    blocks = {};
    for level_num = 1:length(levels)
        %blocks{end+1} = num2str(level_num:length(levels));
        level_str = sprintf('%d ', level_num:length(levels));
        blocks{end+1} = strtrim(level_str);
    end
    %blocks = {'1 2 3 4 5 6 7', '2 3 4 5 6 7', '3 4 5 6 7', '4 5 6 7', '5 6 7', '6 7'};
    current_condition_inSet = (mod(i-1, size_set)+1);
    current_level_inSet = floor((current_condition_inSet-1)/4)+1;
    level=levels(current_level_inSet);
    block = blocks{current_level_inSet};

%     if i_fullSet*size_set+1<=i && i<=i_fullSet*size_set+4
%         level=levels(1);
%         block = blocks{1};
%     elseif i_fullSet*size_set+5<=i && i<=i_fullSet*size_set+8
%         level=levels(2);
%         block = blocks{2};
%     elseif i_fullSet*size_set+9<=i && i<=i_fullSet*size_set+12
%         level=levels(3);
%         block = blocks{3};
%     elseif i_fullSet*size_set+13<=i && i<=i_fullSet*size_set+16
%         level=levels(4);
%         block = blocks{4};
%     elseif i_fullSet*size_set+17<=i && i<=i_fullSet*size_set+20
%         level=levels(5);
%         block = blocks{5};
%     elseif i_fullSet*size_set+21<=i && i<=i_fullSet*size_set+24
%         level=levels(6);
%         block = blocks{6};
%     end

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
    
    data_row{end+1} = sprintf('pic(%s.png,%.2f,%.2f,%.2f,%.2f)', target, target_loc(1), target_loc(2), target_im_size(1), target_im_size(2));
    data_row{end+1} = sprintf('pic(%s.png,%.2f,%.2f,%.2f,%.2f)', distractor, distractor_loc(1), distractor_loc(2), target_im_size(1), target_im_size(2));

    
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
