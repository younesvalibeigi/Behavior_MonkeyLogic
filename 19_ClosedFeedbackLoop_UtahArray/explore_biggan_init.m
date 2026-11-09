%% explore_biggan_init.m
% Try different settings for the block-1 starting point and SEE the images,
% without saving or changing biggan_init_scaled.mat.
%
% Each row of the figure = one setting (CLASS_STD, CLASS_SCALE, seed),
% showing 10 images drawn exactly as block 1 would be:
%   init_z     = [0.7*randn(1,128), CLASS_STD*randn(1,128)]   (real BigGAN units)
%   init_codes = init_z_opt + INIT_SIGMA * N(0, I)            (optimiser units)
%   images     = BigGAN(toBigGAN(init_codes))
%
% CLASS_STD   : how far the starting class embedding is from the centre of the
%               embedding space (centre = "average ImageNet class" ~ dogs)
%               -> changes WHICH kind of object the block starts from
% CLASS_SCALE : how much the class part varies between the 40 images
%               (and how fast it can move during evolution)
%               -> changes HOW MANY kinds of object appear within a block
% INIT_SEED   : a different random starting point with the same settings
%
% Pick the row you like, then put the same CLASS_STD, CLASS_SCALE and
% INIT_SEED in make_biggan_init.m (and CLASS_SCALE in the userloop).

clear; clc;

%% ===== SETTINGS TO COMPARE (edit freely) =====
CLASS_STD_LIST   = [0.05 0.10 0.20];   % starting distance from the "dog" centre
CLASS_SCALE_LIST = [0.1 0.2 0.3];      % within-block class variation
SEED_LIST        = 1;                  % e.g. [1 2 3] to also compare starting points
N_SHOW           = 10;                 % images per row
INIT_SIGMA       = 0.4;
Z_MAX            = 2;
USE_GPU          = true;

%% ===== Setup =====
if USE_GPU
    parallel.gpu.enableCUDAForwardCompatibility(true);   % harmless if not needed
    gpuDevice;
end
G = load_biggan();

rows = {};  labels = {};
for seed = SEED_LIST
    for cs = CLASS_STD_LIST
        for sc = CLASS_SCALE_LIST
            rng(seed, 'twister');                                         % same draws as make_biggan_init
            init_z     = [0.7*randn(1,128), cs*randn(1,128)];
            init_z_opt = [init_z(1:128), init_z(129:256)/sc];
            codes      = (init_z_opt' + INIT_SIGMA*randn(256, N_SHOW))';
            toBigGAN   = @(c) [max(min(c(:,1:128), Z_MAX), -Z_MAX), sc*c(:,129:256)];

            imgs = generate_biggan(G, toBigGAN(codes), USE_GPU, N_SHOW);  % 256x256x3xN_SHOW
            rows{end+1}   = imtile(imgs, 'GridSize', [1 N_SHOW]); %#ok<SAGROW>
            labels{end+1} = sprintf('seed %d | CLASS\\_STD %.2f | CLASS\\_SCALE %.2f', seed, cs, sc); %#ok<SAGROW>
        end
    end
end

%% ===== Show and save =====
nR = numel(rows);
f = figure('Name', 'Block-1 settings', 'Position', [50 50 1500 160*nR]);
t = tiledlayout(f, nR, 1, 'TileSpacing', 'tight', 'Padding', 'tight');
for r = 1:nR
    nexttile(t); imshow(rows{r}); title(labels{r}, 'FontSize', 9);
end
exportgraphics(f, fullfile(pwd, 'explore_biggan_init.png'), 'Resolution', 100);
fprintf('Saved explore_biggan_init.png (%d settings)\n', nR);