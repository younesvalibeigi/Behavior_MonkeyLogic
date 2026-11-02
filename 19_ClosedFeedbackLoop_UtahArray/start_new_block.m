function [cond2idx5, cond_order, filelist] = start_new_block(IM, imgs_per_block, imgs_per_condition, outdir)
    % Choose 80 images (without replacement) and shuffle
    Ntot = numel(IM);
    perm = randperm(Ntot, imgs_per_block);
    % Arrange into [16 x 5] table of indices
    cond2idx5 = reshape(perm, imgs_per_condition, []).';  % rows are conditions
    % Randomize the order of the 16 conditions in this block
    cond_order = randperm(size(cond2idx5,1));
    % Write all block images to PNGs once and keep the filenames
    filelist = cell(imgs_per_block,1);
    for j = 1:imgs_per_block
        fname = fullfile(outdir, sprintf('blk_img_%03d.png', j));
        imwrite(IM{perm(j)}, fname, 'png');
        filelist{j} = fname;
    end
end