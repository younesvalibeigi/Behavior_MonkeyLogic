% Define the input and output directories
inputDir = 'stimulus';
outputDir = 'stimulus_crop';

% Create the output directory if it does not exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get a list of all PNG files in the input directory
imageFiles = dir(fullfile(inputDir, '*.png'));

% Loop through each file
for k = 1:length(imageFiles)
    % Get the full file path
    filePath = fullfile(inputDir, imageFiles(k).name);
    
    % Read the image
    img = imread(filePath);
    
    % Get image size
    [height, width, ~] = size(img);
    
    % Ensure the image is square
    if height ~= width
        error('The image must be square.');
    end
    
    % Create a circular mask
    radius = height / 2;
    centerX = width / 2;
    centerY = height / 2;
    
    [x, y] = meshgrid(1:width, 1:height);
    mask = (x - centerX).^2 + (y - centerY).^2 <= radius^2;
    
    % Initialize the output image
    croppedImg = 127 * ones(height, width, 3, 'uint8');
    
    % Apply the circular mask to each channel
    for c = 1:3
        channel = img(:,:,c);
        croppedImg(:,:,c) = uint8(mask) .* channel + uint8(~mask) * 127;
    end
    
    % Write the cropped image to the output directory
    [~, name, ext] = fileparts(imageFiles(k).name);
    outputFilePath = fullfile(outputDir, [name, ext]);
    imwrite(croppedImg, outputFilePath);
end

disp('Processing complete.');
