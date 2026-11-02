function [all_names, cond_table, t_total] = build_block_images_biggan(G, codes_block, outdir_abs, outdir_rel, N_COND, IMGS_PER_COND, block_idx, nat_names, useGPU, batchSize)
% build_block_images_biggan  Render one block of BigGAN images and add the
% natural control images.
%
% Steps:
%   1) save this block's codes        -> codes_blk%03d.mat
%   2) render the codes with BigGAN   -> 256x256x3xN uint8
%   3) write the synthetic PNGs       -> blk%03d_img_001.png ... _040.png
%   4) copy the natural images        -> blk%03d_img_041.png ... _050.png
%   5) group the 50 file names into a N_COND x IMGS_PER_COND table
%      (row c = the 10 images shown in condition c)
%
% Inputs:
%   G             : BigGAN dlnetwork from load_biggan()
%   codes_block   : n_syn x 256 codes (40 x 256)
%   outdir_abs    : absolute session folder
%   outdir_rel    : relative session folder (what MonkeyLogic's pic() uses)
%   N_COND        : conditions per block (5)
%   IMGS_PER_COND : images per condition (10)
%   block_idx     : block number, used in the file names
%   nat_names     : cellstr of natural image source files (10)
%   useGPU        : true to render on the GPU
%   batchSize     : images per GPU batch
%
% Outputs:
%   all_names  : (n_syn+n_nat) x 1 cellstr of relative paths
%   cond_table : N_COND x IMGS_PER_COND cellstr
%   t_total    : seconds the whole function took (= pause between blocks)

t_start = tic;

n_syn = size(codes_block, 1);
n_nat = numel(nat_names);
assert(n_syn + n_nat == N_COND*IMGS_PER_COND, ...
    'build_block_images_biggan: %d + %d images do not fill %d conditions x %d images.', ...
    n_syn, n_nat, N_COND, IMGS_PER_COND);

% ---- 1) save codes (so every PNG can be regenerated later) ----
save(fullfile(outdir_abs, sprintf('codes_blk%03d.mat', block_idx)), 'codes_block');

% ---- 2) render ----
imgs = generate_biggan(G, codes_block, useGPU, batchSize);   % 256x256x3xn_syn uint8

% ---- 3) write synthetic PNGs ----
all_names = cell(n_syn + n_nat, 1);
for i = 1:n_syn
    fname = sprintf('blk%03d_img_%03d.png', block_idx, i);
    imwrite(imgs(:,:,:,i), fullfile(outdir_abs, fname));
    all_names{i} = fullfile(outdir_rel, fname);   % relative path for MonkeyLogic
end

% ---- 4) copy natural control images (same 10 every block) ----
for i = 1:n_nat
    src = nat_names{i};
    if ~ischar(src), src = char(src); end
    src_norm = strrep(src, '\', filesep);
    if ~exist(src_norm, 'file')
        src_norm = fullfile(pwd, src_norm);       % try relative to task folder
    end
    if ~exist(src_norm, 'file')
        error('Natural image not found: %s', nat_names{i});
    end
    fname = sprintf('blk%03d_img_%03d.png', block_idx, n_syn + i);
    copyfile(src_norm, fullfile(outdir_abs, fname), 'f');
    all_names{n_syn + i} = fullfile(outdir_rel, fname);
end

% ---- 5) condition table: images 1-10 -> cond 1, 11-20 -> cond 2, ... ----
cond_table = reshape(all_names, IMGS_PER_COND, N_COND).';

t_total = toc(t_start);
end
