function repimg = build_block_repr_image(G, codes_blk, name_list)
% Representative image for montage trajectory: generator-mean if possible; else mean of files.
if ~isempty(G) && ~isempty(codes_blk) && all(size(codes_blk)==[numel(name_list) 4096])
    try
        repimg = G.visualize(mean(codes_blk,1));  % generator decides size (often 227x227x3)
        if isa(repimg,'uint8'), return; end
        repimg = im2uint8(repimg);
        return
    catch
        % fall through to image-mean
    end
end
% Mean of the 40 images on disk
acc = [];
for ii = 1:numel(name_list)
    I = imread(name_list{ii});
    if size(I,3)==1, I = repmat(I,[1 1 3]); end
    I = im2double(imresize(I,[227 227]));
    if isempty(acc), acc = zeros(size(I)); end
    acc = acc + I;
end
repimg = uint8(255 * acc / max(1,numel(name_list)));
end