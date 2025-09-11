function [all_names, cond_table] = build_block_images(G, codes_block, outdir_abs, outdir_rel, N_COND, IMGS_PER_COND, block_idx)
% Build one block of GENERATED images from latent codes and save them.
%
% Inputs:
%   G             : FC6 generator object; G.visualize expects 4096xN
%   codes_block   : IMGS_PER_BLOCK x 4096 double
%   outdir_abs    : absolute path to the output folder (e.g., pwd/250907_160331__evol_stimuli)
%   outdir_rel    : relative path used by MonkeyLogic 'pic(...)' (e.g., '250907_160331__evol_stimuli')
%   N_COND        : number of conditions (e.g., 4)
%   IMGS_PER_COND : images per condition (e.g., 10)
%   block_idx     : integer block index (1-based) for filenames
%
% Outputs:
%   all_names  : IMGS_PER_BLOCKx1 cellstr of relative paths '<outdir_rel>/blk%03d_img_%03d.png'
%   cond_table : N_COND x IMGS_PER_COND cellstr (row i = condition i's images)

IMGS_PER_BLOCK = size(codes_block,1);
imgs = G.visualize(codes_block');      % -> HxWx3xIMGS_PER_BLOCK uint8
if ~isa(imgs,'uint8'), imgs = im2uint8(imgs); end

all_names = cell(IMGS_PER_BLOCK,1);
for i = 1:IMGS_PER_BLOCK
    fname = sprintf('blk%03d_img_%03d.png', block_idx, i);
    fpath = fullfile(outdir_abs, fname);
    imwrite(imgs(:,:,:,i), fpath);
    all_names{i} = fullfile(outdir_rel, fname);  % relative path
end

% Make N_COND×IMGS_PER_COND table of filenames
cond_table = reshape(all_names, IMGS_PER_COND, N_COND).';

end
