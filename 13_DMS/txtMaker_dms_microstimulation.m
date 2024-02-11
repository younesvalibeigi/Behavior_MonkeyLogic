% Define the header row
header_row = {'Condition', 'Frequency', 'Block', 'Timing File', 'TaskObject#1', 'TaskObject#2', 'TaskObject#3', 'TaskObject#4'};

% Define parameters
filename = 'CustomStimulusFile.txt';
imgPrefix = 'cir';
imgSuffix = '.png';
imgCount = 10;
fixPosition = [0, 0];
imgPositions = {[0, 0], [-6, 0], [6, 0], [-3.25, -3.25]};
imgSize = 234.25;
scaleFactor = 1.0;

% Define the data rows
data_rows = cell(imgCount, length(header_row));

for i = 1:imgCount
    block = 1; % You can customize the block value if needed
    imgName = sprintf('%s%d%s', imgPrefix, i-1, imgSuffix); % Adjust the file naming pattern
    
    data_row = {num2str(i), '1', num2str(block), 'dms', sprintf('fix(%.2f,%.2f)', fixPosition(1), fixPosition(2))};
    
    % Generate TaskObject entries with customized positions and sizes
    for j = 1:length(imgPositions)
        imgPosition = imgPositions{j};
        scaledSize = imgSize * scaleFactor;
        data_row{end+1} = sprintf('pic(%s,%.2f,%.2f,%.2f,%.2f)', imgName, imgPosition(1), imgPosition(2), scaledSize, scaledSize);
    end

    data_rows{i, 1:length(data_row)} = data_row;
end

% Combine the header and data rows
rows = [header_row; data_rows];

% Write the rows to a text file
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
