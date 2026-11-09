%% make_biggan_init.m
% ONE-TIME script: creates the fixed starting point used by EVERY
% evoStimTCP_BigGAN session. Run it once from the MonkeyLogic task folder.
%
% CODE CONSTRAINTS (same as the in-silico MEI/LEI script)
%   CMA-ES works in "optimiser units". Before BigGAN renders a code, it is
%   converted with toBigGAN:
%     - noise half (1:128) is clipped to +-Z_MAX        (truncation)
%     - class half (129:256) is multiplied by CLASS_SCALE (smaller steps)
%   CLASS_SCALE = 1 and Z_MAX = Inf give the old, unconstrained behaviour.
%
% It saves to biggan_init_scaled.mat:
%   init_z      : 1 x 256 mean code in real BigGAN units
%                 (128 noise + 128 class embedding)
%   init_z_opt  : the same mean code in optimiser units (CMA-ES starts here)
%   init_codes  : 40 x 256 first population in OPTIMISER units (= block 1),
%                 sampled the way CMA-ES samples its first generation:
%                     code = init_z_opt + init_sigma * N(0, I)
%   init_sigma  : CMA-ES starting step size
%   classScale, zMax : the constraints used (the userloop checks they match)
%
% Because these codes are generated ONCE with a fixed seed and the userloop
% only LOADS them, block 1 shows the exact same 40 images in every session.
%
% If the file already exists, the script does NOT overwrite it (unless
% OVERWRITE = true); it only shows the preview of the existing file.

clear; clc;

%% ===== SETTINGS =====
BIGGAN_DIR  = pwd;    % BigGAN files (load_biggan.m, generate_biggan.m, model) in the task folder
OUT_FILE    = fullfile(pwd, 'biggan_init_scaled.mat');   % old biggan_init.mat is kept
INIT_SEED   = 1;      % fixed seed -> reproducible starting point
POPSIZE     = 40;     % must equal IMGS_PER_BLOCK in the userloop
INIT_SIGMA  = 0.4;    % CMA-ES step size (Carlos: 0.4 or 0.7)
CLASS_STD   = 0.05;   % spread of the starting class embedding (larger = further from the "dog" centre)
CLASS_SCALE = 0.2;%0.1;    % class half moves 10x less than noise half (must match the userloop)
Z_MAX       = 2;      % truncation of the noise half (must match the userloop)
OVERWRITE   = false;  % protects the existing starting point
PREVIEW     = true;   % render the 40 block-1 images so you can check them
USE_GPU     = true;

%% ===== Check the BigGAN files are here =====
for f = {'load_biggan.m', 'generate_biggan.m', 'biggan256_initialized_V2.mat'}
    if ~exist(fullfile(BIGGAN_DIR, f{1}), 'file')
        error('%s not found in %s. Copy the BigGAN files into the task folder.', f{1}, BIGGAN_DIR);
    end
end
addpath(BIGGAN_DIR);

%% ===== GPU: RTX 5060 Ti (compute capability 12.0) needs CUDA forward compatibility =====
if USE_GPU
    parallel.gpu.enableCUDAForwardCompatibility(true);   % must run before any GPU call
    gdev = gpuDevice;                                    % selects and initialises the GPU
    fprintf('Using GPU: %s (compute capability %s)\n', gdev.Name, gdev.ComputeCapability);
end

%% ===== Create the codes (only if the file does not exist yet) =====
if exist(OUT_FILE, 'file') && ~OVERWRITE
    fprintf('%s already exists: not overwritten (set OVERWRITE = true for a NEW starting point).\n', OUT_FILE);
    S = load(OUT_FILE);
    init_codes = S.init_codes;
    CLASS_SCALE = S.classScale;   % preview with the constraints stored in the file
    Z_MAX       = S.zMax;
else
    rng(INIT_SEED, 'twister');

    % Mean code in real BigGAN units: noise ~ N(0, 0.7^2), class embedding ~ N(0, CLASS_STD^2)
    init_z     = [0.7*randn(1,128), CLASS_STD*randn(1,128)];        % 1 x 256
    % Same code in optimiser units (class half divided by CLASS_SCALE)
    init_z_opt = [init_z(1:128), init_z(129:256)/CLASS_SCALE];      % 1 x 256
    % First population, in optimiser units, drawn as CMA-ES does at the start
    init_codes = (init_z_opt' + INIT_SIGMA * randn(256, POPSIZE))'; % 40 x 256

    init_sigma = INIT_SIGMA;   %#ok<NASGU>
    init_seed  = INIT_SEED;    %#ok<NASGU>
    classScale = CLASS_SCALE;  %#ok<NASGU>
    zMax       = Z_MAX;        %#ok<NASGU>
    classStd   = CLASS_STD;    %#ok<NASGU>
    created    = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<NASGU>
    save(OUT_FILE, 'init_z', 'init_z_opt', 'init_codes', 'init_sigma', 'init_seed', ...
        'classScale', 'zMax', 'classStd', 'created');
    fprintf('Saved fixed starting point to %s\n', OUT_FILE);
end

%% ===== Optional preview of the 40 block-1 images =====
if PREVIEW
    % Optimiser units -> real BigGAN codes (same conversion as the userloop)
    toBigGAN = @(c) [max(min(c(:,1:128), Z_MAX), -Z_MAX), CLASS_SCALE*c(:,129:256)];

    G = load_biggan();
    imgs  = generate_biggan(G, toBigGAN(init_codes), USE_GPU, POPSIZE);   % 256x256x3x40 uint8
    tiled = imtile(imgs, 'GridSize', [4 10]);
    preview_file = fullfile(pwd, 'biggan_init_scaled_preview.png');
    imwrite(tiled, preview_file);
    figure('Name', 'Block 1 (fixed) images'); imshow(tiled);
    title('Block 1 images (identical in every session)');
    fprintf('Preview saved to %s\n', preview_file);
end