function repimg = block_repr_image(G, codes_blk, name_list)
% Representative image for a block: generator-mean if possible; else mean of the 40 files.
try
    if ~isempty(G) && ~isempty(codes_blk) && size(codes_blk,2)==4096
        repimg = G.visualize(mean(codes_blk,1));
        if ~isa(repimg,'uint8'), repimg = im2uint8(repimg); end
        return
    end
catch
end
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
