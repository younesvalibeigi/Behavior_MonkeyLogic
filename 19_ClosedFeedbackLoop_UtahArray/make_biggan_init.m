%% make_biggan_init.m
% ONE-TIME script: creates the fixed starting point used by EVERY
% evoStimBigGAN session. Run it once from the MonkeyLogic task folder.
%
% It creates and saves to biggan_init.mat:
%   init_z      : 1 x 256 mean code (128 noise + 128 class embedding),
%                 same formula as your in-silico MEI/LEI script
%   init_codes  : 40 x 256 = the first population (= block 1 images),
%                 sampled around init_z exactly the way CMA-ES samples its
%                 first generation (covariance = identity):
%                     code = init_z + init_sigma * N(0, I)
%   init_sigma  : CMA-ES starting step size
%
% Because these codes are generated ONCE with a fixed seed and the userloop
% only LOADS them, block 1 shows the exact same 40 images in every session.
% After block 1 the sessions diverge, because the neural scores differ.
%
% The script refuses to overwrite an existing biggan_init.mat. Set
% OVERWRITE = true only if you deliberately want a NEW starting point.

clear; clc;

%% ===== SETTINGS =====
BIGGAN_DIR = pwd;   % BigGAN files live in the current (task) folder
if ~exist(fullfile(BIGGAN_DIR, 'load_biggan.m'), 'file')
    error('load_biggan.m not found in the current folder (%s). Copy the BigGAN files here.', BIGGAN_DIR);
end
OUT_FILE   = fullfile(pwd, 'biggan_init.mat');  % saved in the current (task) folder
INIT_SEED  = 1;       % fixed seed -> reproducible starting point
POPSIZE    = 40;      % must equal IMGS_PER_BLOCK in evoStimBigGAN_userloop
INIT_SIGMA = 0.7;     % CMA-ES step size (same as your in-silico code)
OVERWRITE  = false;   % protects the existing starting point
PREVIEW    = true;    % render the 40 images so you can check them
USE_GPU    = true;

%% ===== Protect an existing starting point =====
if exist(OUT_FILE, 'file') && ~OVERWRITE
    error(['%s already exists and all sessions start from it.\n' ...
           'Set OVERWRITE = true only if you want a NEW starting point.'], OUT_FILE);
end

%% ===== Create the codes =====
rng(INIT_SEED, 'twister');

% Mean code: noise part ~ N(0, 0.7^2), class-embedding part ~ N(0, 0.05^2)
init_z = [0.7*randn(1,128), 0.05*randn(1,128)];            % 1 x 256

% First population, drawn the way optimize_biggan draws a generation:
%   arx = xmean + sigma * (B * (D .* randn(n, pop)))   with B = I, D = 1 at start
init_codes = (init_z' + INIT_SIGMA * randn(256, POPSIZE))'; % 40 x 256

init_sigma = INIT_SIGMA; %#ok<NASGU>
init_seed  = INIT_SEED;  %#ok<NASGU>
created    = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<NASGU>
save(OUT_FILE, 'init_z', 'init_codes', 'init_sigma', 'init_seed', 'created');
fprintf('Saved fixed starting point to %s\n', OUT_FILE);

%% ===== Optional preview of the 40 block-1 images =====
if PREVIEW
    addpath(BIGGAN_DIR);
    G = load_biggan();
    imgs = generate_biggan(G, init_codes, USE_GPU, POPSIZE);   % 256x256x3x40 uint8
    tiled = imtile(imgs, 'GridSize', [4 10]);
    preview_file = fullfile(pwd, 'biggan_init_preview.png');
    imwrite(tiled, preview_file);
    figure('Name','Block 1 (fixed) images'); imshow(tiled);
    title('Block 1 images (identical in every session)');
    fprintf('Preview saved to %s\n', preview_file);
end
