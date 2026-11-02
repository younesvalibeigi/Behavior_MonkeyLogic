function scores = score_block_images(name_list, net, alex_layer, iPos, iNeg)
% Score IMGS_PER_BLOCK images using AlexNet; return column vector of scores.
IMGS_PER_BLOCK = numel(name_list);
scores = nan(IMGS_PER_BLOCK,1);
if isempty(net), return; end
acts_fc6 = zeros(IMGS_PER_BLOCK,4096,'single');
for ii = 1:IMGS_PER_BLOCK
    I = imread(name_list{ii});
    if size(I,3)==1, I = repmat(I,[1 1 3]); end
    I = imresize(I, [227 227]);
    a = activations(net, I, alex_layer);
    acts_fc6(ii,:) = single(squeeze(a))';
end
scores = acts_fc6(:,iPos);% - acts_fc6(:,iNeg);
end