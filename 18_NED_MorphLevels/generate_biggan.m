function imgs = generate_biggan(net, codes, useGPU, batchSize)
%GENERATE_BIGGAN N-by-256 codes -> 256-by-256-by-3-by-N uint8 RGB.
% Columns 1:128 are noise; 129:256 are continuous class embeddings.
% CPU is the default. Set useGPU=true for a supported GPU and Parallel
% Computing Toolbox. Reduce batchSize if device memory is limited.
arguments
    net (1,1) dlnetwork
    codes (:,256) {mustBeNumeric,mustBeReal,mustBeFinite}
    useGPU (1,1) logical = false
    batchSize (1,1) double {mustBeInteger,mustBePositive} = 2
end
imgs = zeros(256,256,3,size(codes,1),'uint8');
for first = 1:batchSize:size(codes,1)
    ids = first:min(first+batchSize-1,size(codes,1));
    z = single(codes(ids,:));
    if useGPU, z = gpuArray(z); end
    out = extractdata(predict(net,dlarray(z,'BC'),'Acceleration','none'));
    if isa(out,'gpuArray'), out = gather(out); end
    % Preserve Ahyan's V2 output conversion (the two permutations cancel).
    out = permute(out,[4 3 1 2]);
    out = permute(out,[3 4 2 1]);
    assert(isequal(size(out,1),256) && size(out,2)==256 && ...
        size(out,3)==3 && size(out,4)==numel(ids), ...
        'BigGAN:OutputShape','Unexpected V2 network output dimensions.');
    imgs(:,:,:,ids) = uint8(255*max(0,min(1,(out+1)/2)));
end
end
