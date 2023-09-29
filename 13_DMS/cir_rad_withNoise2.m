%% stimulus pattern
folder = 'stimulus';
if ~exist(folder, 'dir')
    mkdir(folder);
end

imagesize = 75;
cyclesPerRadius = 7.5;
pixelperCycle = (imagesize/2)/cyclesPerRadius;%5; % for circular grating

numberOfCycles = 11; % for radial graing
noise_w = 100;
[cir, ~] = cir_grating(imagesize, pixelperCycle, noise_w);
[rad, ~] = rad_grating(imagesize, numberOfCycles, noise_w); 
empty = uint8(ones(imagesize, imagesize, 3)*127);
morphedImage = uint8((0.5) * double(cir) + (0.5) * double(rad));
% Defining the number of intermediate images between each end and the white
% noise in the middle
num = 30; %number of images = num*2+3
num_images = num*2+3;
alpha = 2.7;
figure,
for i=0:num
    wn = simple_WN(imagesize);
    wn_disp = ablend(uint8(wn), empty, alpha);
    subplot(3,num_images, i+1); imshow(wn_disp);
    SNR = cal_snr(cir,wn); %title(['SNR: ' num2str(SNR) ' dB']);
    imwrite(wn_disp, fullfile(folder, ['wn' num2str(i) '.png']));

    if i==0
       cir_disp = ablend(cir, empty, alpha);
       subplot(3,num_images, i+num_images+1), imshow(cir_disp);
       SNR = cal_snr(cir,cir); %title(['SNR: ' num2str(SNR) ' dB']);
       rad_disp = ablend(rad, empty, alpha);
       subplot(3,num_images, i+num_images*2+1), imshow(rad_disp);
       SNR = cal_snr(rad,rad); %title(['SNR: ' num2str(SNR) ' dB']);
       
       imwrite(cir_disp, fullfile(folder, ['cir' num2str(i) '.png']));
       imwrite(rad_disp, fullfile(folder, ['rad' num2str(i) '.png']));
    else
        % Add noise to the images
        [cir_noise, rad_noise] = add_same_wn(cir, rad, 25*i, 0.1);%1*(i));
        % Adjust the contrast level
        cir_noise_disp = ablend(cir_noise, empty, alpha);
        rad_noise_disp = ablend(rad_noise, empty, alpha);

        
        %cir_noise = imhistmatch(cir_noise(:,:,1),cir, 'method', 'polynomial');
        %rad_noise = imhistmatch(rad_noise(:,:,1),rad, 'method', 'polynomial');
        %cir_noise = histeq(cir_noise, imhist(cir));
        %rad_noise = histeq(rad_noise, imhist(rad));
        %cir_noise = imadjust(cir_noise, stretchlim(cir), []);
        %rad_noise = imadjust(rad_noise, stretchlim(rad), []);
        

        subplot(3,num_images, i+num_images+1), imshow(cir_noise_disp);
        SNR = cal_snr(cir,cir_noise); %title(['SNR: ' num2str(SNR) ' dB']);
        subplot(3,num_images, i+num_images*2+1), imshow(rad_noise_disp);
        SNR = cal_snr(rad,rad_noise); %title(['SNR: ' num2str(SNR) ' dB']);

        %cir = cir_noise;
        %rad = rad_noise;
        imwrite(cir_noise_disp, fullfile(folder, ['cir' num2str(i) '.png']));
        imwrite(rad_noise_disp, fullfile(folder, ['rad' num2str(i) '.png']));

    end
end

%% Stimuli: Contrast Adjusted

folder = 'stimulus';
if ~exist(folder, 'dir')
    mkdir(folder);
end
%cir = imread('cir.png');
%rad = imread('rad.png');

%figure, subplot(1,2,1), imshow(cir), subplot(1,2,2), imshow(rad);


imagesize = 75;
pixelperCycle = 5; % for circular grating
numberOfCycles = 11; % for radial graing
noise_w = 100;
[cir, ~] = cir_grating(imagesize, pixelperCycle, noise_w);
[rad, ~] = rad_grating(imagesize, numberOfCycles, noise_w); 

%figure, subplot(1,2,1), imshow(ablend(cir, empty, 3)), subplot(1,2,2), imshow(ablend(rad, empty, 3));


% Defining the number of intermediate images between each end and the white
% noise in the middle
num = 5; %number of images = num*2+3
num_images = num*2+3;


imagesize = size(cir); imagesize = imagesize(1);

empty = uint8(ones(imagesize, imagesize, 3)*127);
morphedImage = uint8((0.5) * double(cir) + (0.5) * double(rad));



wn = simple_WN(imagesize);


%figure, imshow(wn);


%[wn, ~] = add_same_wn(empty, empty, 1, 1);
% wn = NoDecay_WN(imagesize);
%wn = whiteNoise(imagesize, 400);
%wn = histeq(wn, imhist(morphedImage));
% wn = imhistmatch(wn,morphedImage(:,:,1), 'method', 'polynomial');
%wn = imadjust(wn, stretchlim(morphedImage), []);

alpha = 3;
figure,
wn_disp = ablend(uint8(wn), empty, alpha);
subplot(1,num_images,num+2); imshow(wn_disp);
SNR = cal_snr(cir,wn); title(['SNR: ' num2str(SNR) ' dB']);

imwrite(wn_disp, fullfile(folder, 'wn.png'));


for i=0:num
    if i==0
       cir_disp = ablend(cir, empty, alpha);
       subplot(1,num_images, 1), imshow(cir_disp);
       SNR = cal_snr(cir,cir); title(['SNR: ' num2str(SNR) ' dB']);
       rad_disp = ablend(rad, empty, alpha);
       subplot(1,num_images, num_images), imshow(rad_disp);
       SNR = cal_snr(rad,rad); title(['SNR: ' num2str(SNR) ' dB']);
       
       imwrite(cir_disp, fullfile(folder, ['cir' num2str(i) '.png']));
       imwrite(rad_disp, fullfile(folder, ['rad' num2str(i) '.png']));
    else
        % Add noise to the images
        [cir_noise, rad_noise] = add_same_wn(cir, rad, 100*i, 0.1);%1*(i));
        % Adjust the contrast level
        cir_noise_disp = ablend(cir_noise, empty, alpha);
        rad_noise_disp = ablend(rad_noise, empty, alpha);

        
        %cir_noise = imhistmatch(cir_noise(:,:,1),cir, 'method', 'polynomial');
        %rad_noise = imhistmatch(rad_noise(:,:,1),rad, 'method', 'polynomial');
        %cir_noise = histeq(cir_noise, imhist(cir));
        %rad_noise = histeq(rad_noise, imhist(rad));
        %cir_noise = imadjust(cir_noise, stretchlim(cir), []);
        %rad_noise = imadjust(rad_noise, stretchlim(rad), []);
        

        subplot(1,num_images, i+1), imshow(cir_noise_disp);
        SNR = cal_snr(cir,cir_noise); title(['SNR: ' num2str(SNR) ' dB']);
        subplot(1,num_images, num_images-i), imshow(rad_noise_disp);
        SNR = cal_snr(rad,rad_noise); title(['SNR: ' num2str(SNR) ' dB']);

        %cir = cir_noise;
        %rad = rad_noise;
        imwrite(cir_noise_disp, fullfile(folder, ['cir' num2str(i) '.png']));
        imwrite(rad_noise_disp, fullfile(folder, ['rad' num2str(i) '.png']));

    end
end

%% functions
function result = ablend(image, empty, alpha)
    %alpha = 3;
    if ndims(image)==3
        image = image(:,:,1);
    end
    
    [imagesize ~] = size(image);
    gauss = gausswin(imagesize, alpha) * gausswin(imagesize, alpha)';
    result = uint8(gauss .* double(image) + (1 - gauss) .* double(empty));
    
    %result = clean_around(image, empty);
end

function image = clean_around(image, empty)
    [height, width] = size(image);

    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            %rand_value = -1 + (2 * rand);
            %pert = rand_value*((x_center-r)*127/x_center);
            %pert = rand_value*((x_center)*127/x_center);
            if r>x_center
                image(y,x) = empty(y,x,1);
            end
    
        end
    end
end

function SNR = cal_snr(sig, sig_noise)
    if ndims(sig)==3
        sig = sig(:,:,1);
    end
    if ndims(sig_noise)==3
        sig_noise = sig_noise(:,:,1);
    end
    sig = double(sig);
    sig_noise = double(sig_noise);
    %noise = sig-sig_noise;
    % Calculate the SNR in decibels
    %SNR = 10 * log10(sum(sig(:).^2) / sum(noise(:).^2));
    SNR = snr(sig, sig - sig_noise);
end

function [cir_noise, rad_noise] = add_same_wn(cir, rad, repetition,noise_w)
% noise_w should be between 0 and 1
% repetition is how many times white noise is added to the image
% you should play with repetition and noise_w to get the best result
    if ndims(cir) == 2
        [height, width] = size(cir);
    elseif ndims(cir) == 3
        [height, width, z] = size(cir);
    end
    for i=1:repetition
        %wn = centerDecay_WN(height);
        wn = simple_WN(height);
        noise_mat = (double(wn)-127)*noise_w;
        %noise_mat_cir = imhistmatch(noise_mat, double(cir(:,:,1)));
        %noise_mat_rad = imhistmatch(noise_mat, double(rad(:,:,1)));
        cir = uint8(double(cir)+noise_mat);
        rad = uint8(double(rad)+noise_mat);
    end
    cir_noise = cir;
    rad_noise = rad;
end

function wn = simple_WN(imagesize)
    wn = rand(imagesize)*255;
    % Adjust the average to 127
    wn = wn - mean(wn(:)) + 127;
end

function wn = centerDecay_WN(imagesize)
    %imagesize = 128;
    wn = ones(imagesize, imagesize, 'uint8')*127;
    [height, width] = size(wn);

    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            rand_value = -1 + (2 * rand);
            pert = rand_value*((x_center-r)*127/x_center);
            %pert = rand_value*((x_center)*127/x_center);
            if r<=x_center
                wn(y,x) = uint8(double(wn(y,x))+pert);
            end
    
        end
    end
end

function wn = NoDecay_WN(imagesize)
    %imagesize = 128;
    wn = ones(imagesize, imagesize, 'uint8')*127;
    [height, width] = size(wn);

    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            rand_value = -1 + (2 * rand);
            %pert = rand_value*((x_center-r)*127/x_center);
            pert = rand_value*((x_center)*127/x_center);
            if r<=x_center
                wn(y,x) = uint8(double(wn(y,x))+pert);
            end
    
        end
    end
end
%%
function imageMatrix_noise = add_whiteNoise(imageMatrix, noise_w)
   
    [height, width, z] = size(imageMatrix);
    imageMatrix_noise = ones(height, width, 'uint8')*127;
    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            if r<=x_center
                pixelValue = double(imageMatrix(y,x));
                
                
                % noisy image
                noiseAmplitude = (1 - (r / x_center)) * 0.5;
                noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1)); % Generate noise with positive and negative values
                
              
                %noise = (2 * rand - 1) * (x_center-r)*10;
                mappedValue_noise = pixelValue - noise;
                mappedValue_noise = uint8(mappedValue_noise);
                imageMatrix_noise(y,x) = mappedValue_noise;
            end
    
        end
    end
end


function [imageMatrix imageMatrix_noise] = cir_grating(imageSize, pixelsPerPeriod, noise_w)
    %imageSize = 128;
    imageMatrix = ones(imageSize, imageSize, 'uint8')*127;
    imageMatrix_noise = ones(imageSize, imageSize, 'uint8')*127;
    [height, width] = size(imageMatrix);
    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    
    % params for the circular gratings
    tiltInDegrees = 0; % The tilt of the grating in degrees.
    tiltInRadians = tiltInDegrees * pi / 180; % The tilt of the grating in radians.
    % *** To lengthen the period of the grating, increase pixelsPerPeriod.
    %pixelsPerPeriod = 8; % How many pixels will each period/cycle occupy?
    spatialFrequency = 1 / pixelsPerPeriod; % How many periods/cycles are there in a pixel?
    radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)
    a=cos(tiltInRadians)*radiansPerPixel;
    %range = 1:x_center;
    %r_ref = sin(range*a)%.*exp(-range*0.1))+1)*127.5;
    %figure,plot(r_ref)
    
    % Generate noise with varying amplitude
    %noise_w = 200;
    %noiseAmplitude = (1 - (range / x_center)) * 0.5; % Noise amplitude decreases gradually
    %noise = noise_w*(noiseAmplitude .* (2 * rand(size(range)) - 1)); % Generate noise with positive and negative values
    %r_ref = r_ref + noise;
    %%% noise = pinknoise(length(range));
    %r_ref = noise'*1000+r_ref;
    %hold on, plot(r_ref), hold off
    
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            %if r<=x_center
                pixelValue = sin(r*a);%*exp(-r*(128*0.07/imageSize));

                mappedValue = (pixelValue + 1) * 127.5;  % Scale to the range [0, 255]
                
                
                % noisy image
                noiseAmplitude = (1 - (r / x_center)) * 0.5;
                noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1)); % Generate noise with positive and negative values
                
                % Convert mapped values to uint8 format
                mappedValue = uint8(mappedValue);
                imageMatrix(y,x) = mappedValue;
                %noise = (2 * rand - 1) * (x_center-r)*10;
                mappedValue_noise = mappedValue - noise;
                mappedValue_noise = uint8(mappedValue_noise);
                imageMatrix_noise(y,x) = mappedValue_noise;
            %end
    
        end
    end
end


function [imageMatrix imageMatrix_noise] = rad_grating(imageSize, num_cyc, noise_w) 
    %imageSize = 128;
    imageMatrix = ones(imageSize, imageSize, 'uint8')*127;
    imageMatrix_noise = ones(imageSize, imageSize, 'uint8')*127;
    [height, width] = size(imageMatrix);
    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
        
    
    %num_cyc = 11; % the number of periods for radial graing
    
    
    
    % range = 1:0.1:x_center*2*pi;
    % theta_ref = sin(range*a);%((sin(range*a))+1)*127.5;
    % figure,plot(theta_ref)
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            % Calculate the polar angle (theta) based on (x, y) coordinates
            theta = atan2(y - y_center, x - x_center);
            
            %if r<=x_center
                pixelValue = sin(theta*num_cyc);%*exp(-r*(128*0.07/imageSize));
                mappedValue = (pixelValue + 1) * 127.5;  % Scale to the range [0, 255]
                % Convert mapped values to uint8 format
                mappedValue = uint8(mappedValue);
                imageMatrix(y,x) = mappedValue;
                
                % noisy image
                %noise_w = 100;
                noiseAmplitude = (1 - (r / x_center)) * 0.5;
                noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1)); % Generate noise with positive and negative values
                
                % Convert mapped values to uint8 format
                mappedValue = uint8(mappedValue);
                imageMatrix(y,x) = mappedValue;
                %noise = (2 * rand - 1) * (x_center-r)*10;
                mappedValue_noise = mappedValue - noise;
                mappedValue_noise = uint8(mappedValue_noise);
                imageMatrix_noise(y,x) = mappedValue_noise;
            %end
    
    
        end
    end
end

function imageMatrix_noise = whiteNoise(imageSize, noise_w)
    %imageSize = 128;
    imageMatrix_noise = ones(imageSize, imageSize, 'uint8')*127;
    [height, width] = size(imageMatrix_noise);
    x_center = (width + 1) / 2;  % Calculate the x-coordinate of the image center
    y_center = (height + 1) / 2;  % Calculate the y-coordinate of the image center
    
    
    for y = 1:height
        for x = 1:width
            % Access the pixel value at (x, y)
            %pixelValue = imageMatrix(y, x);
            r = sqrt((x - x_center).^2 + (y - y_center).^2);
            %if r<=x_center
                % noisy image
                noiseAmplitude = (1 - (r / x_center)) * 0.5;
                noise = noise_w*(noiseAmplitude * (2 * rand(1) - 1)); % Generate noise with positive and negative values
                
                % Convert uint8 to double
                pixelValue = double(imageMatrix_noise(y,x));
                pixelValue = pixelValue - noise;
                % Convert mapped values to uint8 format
                imageMatrix_noise(y,x) = uint8(pixelValue);
            %end
    
        end
    end
end

