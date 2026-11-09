%% make_cirRad_noise_levels.m
% Makes n_levels noise levels in total between cir0.png (LEI) and rad0.png (MEI)
% by mixing each stimulus with white noise inside a circular aperture. Outside
% the circle (the four corners) every image is a uniform grey background.
% Saved as
%   LEI_0, LEI_1, ..., LEI_mid, MEI_mid, ..., MEI_1, MEI_0
% LEI_0 = pure cir, MEI_0 = pure rad, LEI_mid = MEI_mid = the same full-noise
% image (LEI_4 = MEI_4 when n = 9), so there are n_levels distinct images.
%
% Luminance/contrast matching: at every level, the area inside the circle
% has the same mean luminance (= background grey) and the same RMS contrast
% (targetRMS), for both cir and rad. Only the signal-to-noise ratio changes.
% The same noise image is used for cir and rad at a given level.
%
% Output folder (in the current MATLAB folder):
%   yymmdd_<label>_HHMM_noise_cirRad_n<n_levels>
% where <label> is the next free letter (a, b, c, ...) among today's folders.
% SNR values and per-image luminance stats are saved as noise_levels.csv/.mat.
clear; clc;

%% ---------------- Settings ----------------
n_levels   = 9;          % total levels incl. pure cir and pure rad (odd number)
srcFolder  = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\NIMHMonkeyLogic20x2E4@2.4.2\task\Behavior_MonkeyLogic\15_RFmap_stimShow_DMS_DiffLatency\stimulus';
leiName    = 'cir0.png'; % LEI = circular
meiName    = 'rad0.png'; % MEI = radial

bgLevel    = 0.5;        % grey background (0-1); also the mean luminance inside the circle
radiusFrac = 1.0;        % circle radius as a fraction of half the image's shorter side
edgeWidth  = 0;          % width (px) of a soft cosine edge on the circle; 0 = hard edge
noiseType  = 'gaussian'; % 'gaussian' or 'uniform' white noise
seed       = 1;          % random seed (saved, so the noise can be reproduced)
targetRMS  = [];         % RMS contrast inside the circle (0-1 units);
                         % [] = the lower of the two stimuli's own RMS contrast

%% ---------------- Output folder: yymmdd_<label>_HHMM_<name> ----------------
nowDT    = datetime('now');
dateStr  = char(nowDT, 'yyMMdd');    % e.g. 261023
timeStr  = char(nowDT, 'HHmm');      % e.g. 1645
baseName = sprintf('noise_cirRad_n%d', n_levels);

% Find labels already used today (files or folders named yymmdd_<letter>_...)
existing = dir(fullfile(pwd, [dateStr '_*']));
used = '';
for i = 1:numel(existing)
    tok = regexp(existing(i).name, ['^' dateStr '_([a-z])_'], 'tokens', 'once');
    if ~isempty(tok), used(end+1) = tok{1}; end %#ok<AGROW>
end
if isempty(used)
    label = 'a';
else
    label = char(max(used) + 1);
end
if label > 'z'
    error('All labels a-z are already used for %s.', dateStr);
end

outFolder = fullfile(pwd, sprintf('%s_%s_%s_%s', dateStr, label, timeStr, baseName));
mkdir(outFolder);
fprintf('Output folder: %s\n', outFolder);

%% ---------------- Load images (grayscale, 0-1) ----------------
lei_img = load_gray(fullfile(srcFolder, leiName));
mei_img = load_gray(fullfile(srcFolder, meiName));
if ~isequal(size(lei_img), size(mei_img))
    error('%s and %s must be the same size (got %s vs %s).', leiName, meiName, ...
        mat2str(size(lei_img)), mat2str(size(mei_img)));
end
[H, W] = size(lei_img);

%% ---------------- Circular aperture ----------------
[X, Y] = meshgrid(1:W, 1:H);
r = hypot(X - (W+1)/2, Y - (H+1)/2);
R = radiusFrac * min(H, W) / 2;
win = double(r <= R - edgeWidth);
if edgeWidth > 0
    ramp = r > R - edgeWidth & r <= R;
    win(ramp) = 0.5 * (1 + cos(pi * (r(ramp) - (R - edgeWidth)) / edgeWidth));
end
core = r <= R - edgeWidth;           % pixels used for luminance/contrast stats

%% ---------------- Normalise stimuli (zero mean, unit RMS inside circle) ----------------
rmsLEI = std(lei_img(core), 1);
rmsMEI = std(mei_img(core), 1);
if isempty(targetRMS)
    targetRMS = min(rmsLEI, rmsMEI);
end
fprintf('Original RMS contrast: cir = %.3f, rad = %.3f -> target = %.3f\n', rmsLEI, rmsMEI, targetRMS);

stims    = {unit_rms(lei_img, core), unit_rms(mei_img, core)};
stimTag  = {'LEI', 'MEI'};
stimFile = {leiName, meiName};

%% ---------------- Noise images (one per level, shared by cir and rad) ----------------
if mod(n_levels, 2) == 0
    error('n_levels must be odd so LEI and MEI share one full-noise image.');
end
nPer = ceil(n_levels / 2);           % levels per stimulus (5 when n = 9)
rng(seed);
noises = cell(nPer, 1);
for k = 1:nPer
    switch lower(noiseType)
        case 'gaussian', nz = randn(H, W);
        case 'uniform',  nz = rand(H, W) - 0.5;
        otherwise, error('noiseType must be ''gaussian'' or ''uniform''.');
    end
    noises{k} = unit_rms(nz, core);
end

%% ---------------- Noise levels ----------------
%p = linspace(0, 1, nPer);            % noise fraction: 0 = pure stimulus, 1 = full noise
p = [0, 0.25, 0.40, 0.55, 1];
rows = {};
figure('Name', 'cir / rad noise levels');
for s = 1:2
    for k = 1:nPer
        sig = (1 - p(k)) * stims{s};
        nz  = p(k) * noises{k};
        mix = sig + nz;
        sc  = targetRMS / std(mix(core), 1);   % same RMS contrast at every level

        img = bgLevel + win .* (sc * mix);     % mean inside circle = bgLevel, corners = grey
        clippedPct = 100 * mean(img(core) < 0 | img(core) > 1);
        img = min(max(img, 0), 1);

        % SNR (power ratio inside the circle) of the components actually used
        sigPow   = var(sc * sig(core), 1);
        noisePow = var(sc * nz(core), 1);
        snr      = sigPow / noisePow;          % Inf at level 0, 0 at full noise
        snr_dB   = 10 * log10(snr);

        name = sprintf('%s_%d', stimTag{s}, k - 1);
        imwrite(im2uint8(img), fullfile(outFolder, [name '.png']));

        rows(end+1, :) = {string(stimFile{s}), string(stimTag{s}), k - 1, p(k), ...
            snr, snr_dB, mean(img(core)), std(img(core), 1), clippedPct, string(name)}; %#ok<SAGROW>
        fprintf('%s  noise = %.3f  SNR = %.3g (%.2f dB)  mean = %.3f  RMS = %.3f  clipped = %.2f%%\n', ...
            name, p(k), snr, snr_dB, mean(img(core)), std(img(core), 1), clippedPct);

        % Preview
        % Preview in one row: LEI_0 ... LEI_mid, then MEI_mid-1 ... MEI_0
        if s == 1
            subplot(1, n_levels, k);
        elseif k < nPer
            subplot(1, n_levels, n_levels - k + 1);
        else
            continue;                          % MEI_mid = LEI_mid, already shown
        end
        imshow(img);
        title(sprintf('%s\np=%.2f', name, p(k)), 'Interpreter', 'none', 'FontSize', 7);
    end
end

%% ---------------- Save SNR values and stats ----------------
T = cell2table(rows, 'VariableNames', {'source', 'stim', 'level', 'noise_frac', ...
    'SNR', 'SNR_dB', 'mean_lum', 'rms_contrast', 'clipped_pct', 'file'});
writetable(T, fullfile(outFolder, 'noise_levels.csv'));
mask = win;
save(fullfile(outFolder, 'noise_levels.mat'), 'T', 'p', 'n_levels', 'nPer', 'seed', 'noiseType', ...
    'bgLevel', 'radiusFrac', 'edgeWidth', 'targetRMS', 'mask', 'leiName', 'meiName', 'srcFolder');

if max(T.clipped_pct) > 1
    warning('Up to %.1f%% of pixels were clipped; lower targetRMS for better luminance matching.', ...
        max(T.clipped_pct));
end
fprintf('Done. Saved to:\n%s\n', outFolder);

%% ---------------- Helper functions ----------------
function img = load_gray(f)
% Reads an image as grayscale double in [0, 1].
    img = im2double(imread(f));
    if size(img, 3) == 3
        img = rgb2gray(img);
    elseif size(img, 3) > 1
        img = img(:, :, 1);
    end
end

function z = unit_rms(img, core)
% Zero mean and unit RMS inside the aperture.
    z = img - mean(img(core));
    z = z / std(z(core), 1);
end