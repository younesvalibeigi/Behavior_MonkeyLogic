% make_cirRad_morph.m
%
% Creates a 9-level morph sequence between cir0.png and rad0.png
% using the same pixel-space technique as process_last_block_avg_morph()
% (and its slerp counterpart) from the XDream analysis script.
%
% Linear morph:  morph = (1-alpha)*img1 + alpha*img2
% Slerp morph:   spherical interpolation of the flattened pixel vectors
%
% Set useSlerp = true/false below to choose which technique to use.

clear; clc;

%% ---- Paths ----
srcFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\15_RFmap_stimShow_DMS_DiffLatency\stimulus';
outFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_NED_Training\cirRadMorph';

img1Name = 'cir0.png';
img2Name = 'rad0.png';

numSteps = 9;      % total images in the morph, including both endpoints
useSlerp = true;  % set true to use spherical interpolation instead of linear

%% ---- Setup ----
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

img1 = imread(fullfile(srcFolder, img1Name));
img2 = imread(fullfile(srcFolder, img2Name));

% Make sure both images are the same size/class before interpolating
if ~isequal(size(img1), size(img2))
    error('cir0.png and rad0.png must be the same size (got %s vs %s).', ...
        mat2str(size(img1)), mat2str(size(img2)));
end

img1 = double(img1);
img2 = double(img2);

%% ---- Generate morph levels ----
figure;

if ~useSlerp
    % ---- Linear interpolation (pixel space) ----
    for k = 1:numSteps
        alpha = (k-1)/(numSteps-1); % 0 -> 1
        morph_img = (1-alpha)*img1 + alpha*img2;
        morph_img = uint8(morph_img);

        subplot(1, numSteps, k)
        imshow(morph_img)
        title(sprintf('%.2f', alpha))

        outName = fullfile(outFolder, sprintf('cirRadMorph_linear%d.png', k));
        imwrite(morph_img, outName);
        fprintf('Saved %s\n', outName);
    end

else
    % ---- Spherical interpolation (slerp, pixel space) ----
    v1 = img1(:);
    v2 = img2(:);

    v1n = v1 / norm(v1);
    v2n = v2 / norm(v2);

    cosTheta = dot(v1n, v2n);
    cosTheta = max(min(cosTheta,1),-1); % clamp numerical errors
    theta = acos(cosTheta);

    for k = 1:numSteps
        alpha = (k-1)/(numSteps-1);

        if abs(theta) < 1e-6
            % vectors nearly identical -> fall back to linear
            v = (1-alpha)*v1 + alpha*v2;
        else
            v = (sin((1-alpha)*theta)/sin(theta))*v1 + (sin(alpha*theta)/sin(theta))*v2;
        end

        morph_img = reshape(v, size(img1));
        morph_img = uint8(morph_img);

        subplot(1, numSteps, k)
        imshow(morph_img)
        title(sprintf('%.2f', alpha))

        outName = fullfile(outFolder, sprintf('cirRadMorph_slerp%d.png', k));
        imwrite(morph_img, outName);
        fprintf('Saved %s\n', outName);
    end
end

fprintf('Done. %d morph levels saved to:\n%s\n', numSteps, outFolder);