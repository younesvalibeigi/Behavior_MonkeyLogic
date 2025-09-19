gen_gratings
function gen_gratings()
    % Generate 40 images:
    %  - 30 Gabor stimuli (6 orientations × 5 frequencies)
    %  - 5 Circular gratings (different frequencies)
    %  - 5 Radial gratings (different frequencies)
    %
    % Images are saved in folder 'gratings'

    % ======================
    % Parameters
    % ======================
    outdir = 'gratings';
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
    
    imagesize = 512;
    noise_w = 100;

    % Apply circular mask
    [x,y] = meshgrid(1:imagesize, 1:imagesize);
    r = sqrt((x - imagesize/2).^2 + (y - imagesize/2).^2);
    mask = r <= (imagesize/2);   % inside circle = true

    envelope = max(0, 1 - r/(imagesize/2));  
    %envelope(envelope<0.4) = 0.4;

    % For Gabor
    orientations = [0, 30, 60, 90, 120, 150]; % degrees
    freqs = [0.004, 0.0055, 0.007, 0.0085, 0.01];   % cycles/pixel (spatial freq)

    % For Circular
    cyclesPerRadius_list = [1, 2, 3, 4, 5]; % adjust for variety

    % For Radial
    numCycles_list = [2, 4, 6, 8, 10]; % number of radial cycles

    % ======================
    % Generate Gabor stimuli
    % ======================
    idx = 1;
    for ori = orientations
        cc=1;
        for f = freqs
            img = gabor_grating(imagesize, f, ori);
            filename = fullfile(outdir, sprintf('gabor_ori%d_%d.png', ori, cc));
            cc = cc+1;
            img = envelope .* (double(img) - 128) + 128;
            img(~mask) = 128;  % set outside region to mid-gray (0.5 in [0,1])
            imwrite(uint8(img), filename);
            idx = idx + 1;
        end
    end

    % ======================
    % Generate Circular gratings
    % ======================
    for i = 1:length(cyclesPerRadius_list)
        cyclesPerRadius = cyclesPerRadius_list(i);
        pixelperCycle = (imagesize/2) / cyclesPerRadius;
        [cir, ~] = cir_grating(imagesize, pixelperCycle, noise_w);
        stim = double(cir); stim = envelope .* (stim - 128) + 128;cir = uint8(stim);

        cir(~mask) = 128;  % set outside region to mid-gray (0.5 in [0,1])
        filename = fullfile(outdir, sprintf('circular_%d.png', i));
        imwrite(cir, filename);
        idx = idx + 1;
    end

    % ======================
    % Generate Radial gratings
    % ======================
    for i = 1:length(numCycles_list)
        numCycles = numCycles_list(i);
        [rad, ~] = rad_grating(imagesize, numCycles, noise_w);
        stim = double(rad); stim = envelope .* (stim - 128) + 128;rad = uint8(stim);
        rad(~mask) = 128;  % set outside region to mid-gray (0.5 in [0,1])
        filename = fullfile(outdir, sprintf('radial_%d.png', i));
        imwrite(rad, filename);
        idx = idx + 1;
    end

    fprintf('Generated %d stimuli in folder "%s"\n', idx-1, outdir);
end

% ============================================================
% Helper: Gabor grating
% ============================================================
function img = gabor_grating(imageSize, spatialFreq, orientation)
    % spatialFreq in cycles per pixel
    % orientation in degrees
    [x,y] = meshgrid(1:imageSize, 1:imageSize);
    x = x - imageSize/2;
    y = y - imageSize/2;

    theta = orientation * pi/180;
    x_theta = x*cos(theta) + y*sin(theta);

    grating = sin(2*pi*spatialFreq*x_theta);

    % scale to 0–255
    img = (grating + 1) * 127.5;
end

% ============================================================
% Helper: Circular grating (from your code)
% ============================================================
function [imageMatrix, imageMatrix_noise] = cir_grating(imageSize, pixelsPerPeriod, noise_w)
    imageMatrix = ones(imageSize, imageSize, 'uint8')*127;
    imageMatrix_noise = ones(imageSize, imageSize, 'uint8')*127;
    [height, width] = size(imageMatrix);
    x_center = (width + 1) / 2;
    y_center = (height + 1) / 2;

    for y = 1:height
        for x = 1:width
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            pixelValue = sin(2*pi*r/pixelsPerPeriod+pi/2);
            mappedValue = (pixelValue + 1) * 128;
            noiseAmplitude = (1 - (r / x_center)) * 0.5;
            noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1));
            mappedValue = uint8(mappedValue);
            imageMatrix(y,x) = mappedValue;
            mappedValue_noise = uint8(mappedValue - noise);
            imageMatrix_noise(y,x) = mappedValue_noise;
        end
    end
end

% ============================================================
% Helper: Radial grating (from your code)
% ============================================================
function [imageMatrix, imageMatrix_noise] = rad_grating(imageSize, num_cyc, noise_w)
    imageMatrix = ones(imageSize, imageSize, 'uint8')*127;
    imageMatrix_noise = ones(imageSize, imageSize, 'uint8')*127;
    [height, width] = size(imageMatrix);
    x_center = (width + 1) / 2;
    y_center = (height + 1) / 2;

    for y = 1:height
        for x = 1:width
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            theta = atan2(y - y_center, x - x_center);
            pixelValue = sin(theta*num_cyc);
            mappedValue = (pixelValue + 1) * 127.5;
            mappedValue = uint8(mappedValue);
            imageMatrix(y,x) = mappedValue;

            noiseAmplitude = (1 - (r / x_center)) * 0.5;
            noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1));
            mappedValue_noise = uint8(mappedValue - noise);
            imageMatrix_noise(y,x) = mappedValue_noise;
        end
    end
end
