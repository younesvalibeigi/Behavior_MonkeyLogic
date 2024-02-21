N = 10;
folder = ['rfMapping_' num2str(N) 'X' num2str(N) '_RedGreen'];

% Check if the folder exists, if not, create it
if ~exist(folder, 'dir')
    mkdir(folder);
end

imagesize = 200;

% Define parameters for the first grating
gratingSize = imagesize/N;
frequency = 1;
angle = pi/4;

% Create a grid of coordinates
[x, y] = meshgrid(1:gratingSize, 1:gratingSize);
% Compute the phase of the grating
phase = frequency * (cos(angle) * x + sin(angle) * y);
% Generate the first grating pattern (black and white)
grating_1 = uint8(127 * (sin(phase) > 0));

% Define parameters for the second grating
angle = pi/4 * 3;
% Recompute phase and generate the second grating pattern
phase = frequency * (cos(angle) * x + sin(angle) * y);
grating_2 = uint8(127 * (sin(phase) > 0));

% Loop to generate and save images
for i = 1:(N*N)
    % Initialize the image as a gray background
    image = uint8(ones(imagesize, imagesize, 3)*127);
    
    % Calculate starting indices for the current sub-image
    startRow = 1 + (mod(i-1, N) * gratingSize);
    startCol = 1 + (floor((i-1) / N) * gratingSize);
    
    % Create a black sub-image
    black = repmat(uint8(zeros(gratingSize, gratingSize)), [1 1 3]);
    black(:,:,1) = 255; %Convert black to Red
    % Put the black sub-image in the image
    image(startRow:startRow+gratingSize-1, startCol:startCol+gratingSize-1, :) = black;
    
    % Save the image
    imwrite(image, fullfile(folder, sprintf('rf_10X10_RG_%02d.png', i)));
end

% Loop to generate and save images with white sub-images
for i = 1:(N*N)
    % Initialize the image as a gray background
    image = uint8(ones(imagesize, imagesize, 3)*127);
    
    % Calculate starting indices for the current sub-image
    startRow = 1 + (mod(i-1, N) * gratingSize);
    startCol = 1 + (floor((i-1) / N) * gratingSize);
    
    % Create a white sub-image
    white = repmat(uint8(ones(gratingSize, gratingSize)*255), [1 1 3]);
    white(:,:,1) = 0;white(:,:,2)=255; white(:,:,3)=0; % convert white to green
    % Put the white sub-image in the image
    image(startRow:startRow+gratingSize-1, startCol:startCol+gratingSize-1, :) = white;
    
    % Save the image
    imwrite(image, fullfile(folder, sprintf('rf_10X10_RG_%02d.png', i+N*N)));
end

% Display the first grating pattern (grating_1)
imshow(grating_1);
