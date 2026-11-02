function repimg = block_repr_image_biggan(G, codes_blk, name_list, useGPU)
% block_repr_image_biggan  One representative image per block, for the
% trajectory montage: BigGAN rendering of the block's MEAN code (same idea
% as img_traj in your in-silico MEI/LEI script).
% If rendering fails, falls back to the pixel average of the block's PNGs.
%
% Inputs:
%   G         : BigGAN dlnetwork
%   codes_blk : 40 x 256 codes of the block
%   name_list : file names of the 40 synthetic PNGs (fallback only)
%   useGPU    : true to render on the GPU

try
    if ~isempty(G) && ~isempty(codes_blk) && size(codes_blk, 2) == 256
        repimg = generate_biggan(G, mean(codes_blk, 1), useGPU, 1);   % 256x256x3 uint8
        return
    end
catch ME
    warning('block_repr_image_biggan: rendering failed (%s). Using pixel mean.', ME.message);
end

% ---- fallback: mean of the PNG files ----
acc = [];
for ii = 1:numel(name_list)
    I = imread(name_list{ii});
    if size(I, 3) == 1, I = repmat(I, [1 1 3]); end
    I = im2double(imresize(I, [256 256]));
    if isempty(acc), acc = zeros(size(I)); end
    acc = acc + I;
end
repimg = uint8(255 * acc / max(1, numel(name_list)));
end
