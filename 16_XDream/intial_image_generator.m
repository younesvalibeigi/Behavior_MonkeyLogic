inital_image_generator()


function NAMES = inital_image_generator(N, outdir, imgSize, seed)
% inital_image_generator
% Generate N grayscale images with soft black/white "shadow" patterns.
% Files: stim_images/img_001.png ... img_100.png (default N=100)
% Also saves images.mat with NAMES (Windows-style paths: 'stim_images\img_001.png', ...)
%
% Usage:
%   inital_image_generator            % 100 images, 256x256, folder 'stim_images'
%   inital_image_generator(100,'stim_images',[256 256],42)
%
% Returns:
%   NAMES : cellstr of relative filenames (Windows-style backslashes)

    if nargin < 1 || isempty(N),       N = 100;            end
    if nargin < 2 || isempty(outdir),  outdir = 'stim_images'; end
    if nargin < 3 || isempty(imgSize), imgSize = [256 256]; end
    if nargin < 4 || isempty(seed),    rng('shuffle'); else rng(seed); end

    if ~exist(outdir,'dir'), mkdir(outdir); end

    H = imgSize(1); W = imgSize(2);
    NAMES = cell(N,1);
    codes = zeros(N,4096,'double');   % each row = 1x4096 code for one image


    for i = 1:N
        % ---- make a smooth "shadow" field in [-1, 1] ----
        f = mk_shadow_field(H,W);

        % ---- map to gray background (mean ~128) with soft contrast ----
        amp  = randi([40 80]);                % contrast amplitude (gray levels)
        img  = 128 + amp * f;                  % double
        img  = uint8(min(max(img,0),255));     % clamp to [0,255]

        % Save as 3-channel grayscale (RGB) for compatibility
        rgb = repmat(img, [1 1 3]);

        % ---- derive a 1x4096 code from the grayscale image ----
        % Resize to 64x64 and flatten to a row vector in [0,1]
        small = imresize(img, [64 64], 'bicubic');     % img is already grayscale uint8
        codes(i,:) = reshape(double(small)/255, 1, 4096);

        fname = sprintf('img_%03d.png', i);
        imwrite(rgb, fullfile(outdir, fname));

        % Windows-style relative path in NAMES (as requested)
        NAMES{i} = strrep(fullfile('stim_images', fname), '/', '\');
    end

    % Also save an images.mat for convenience
    save(fullfile(pwd,'images.mat'), 'NAMES', 'codes', '-v7');


end


% ----------------------- helpers -----------------------
function f = mk_shadow_field(H,W)
% Build low-frequency “blurry shadow” texture in [-1, 1]

    % Multi-scale smooth noise
    f = zeros(H,W);
    num_oct = randi([2 4]);                     % 2–4 octaves
    for o = 1:num_oct
        baseH = max(8, round(H / randi([16 32])));   % coarse grid
        baseW = max(8, round(W / randi([16 32])));
        n = imresize(randn(baseH, baseW), [H W], 'bicubic');
        f = f + n / (2^(o-1));
    end

    % Add a few random soft blobs (positive & negative)
    blob = zeros(H,W);
    nblobs = randi([5 20]);
    [X,Y] = meshgrid(1:W,1:H);
    for b = 1:nblobs
        cx = randi([1 W]); cy = randi([1 H]);
        sx = randi([round(W*0.03) round(W*0.15)]);
        sy = randi([round(H*0.03) round(H*0.15)]);
        A  = (rand*2 - 1); % +/- amplitude
        blob = blob + A * exp(-((X-cx).^2/(2*sx^2) + (Y-cy).^2/(2*sy^2)));
    end
    f = f + 0.7*blob;

    % Strong Gaussian blur to keep only “shadowy” structure
    sigma = randi([6 14]);
    f = imgaussfilt(f, sigma);

    % Zero-mean and normalize to [-1, 1], with slight contrast jitter
    f = f - mean(f(:));
    f = f / (max(abs(f(:))) + eps);
    f = f * (0.8 + 0.4*rand);  % 0.8–1.2 scaling
end
