function net = load_biggan()
%LOAD_BIGGAN Load Ahyan's initialized BigGAN V2 from this folder.
root = fileparts(mfilename('fullpath'));
addpath(root); % Required by the saved network's +biggan256_gen_V2 classes.
file = fullfile(root, 'biggan256_initialized_V2.mat');
assert(isfile(file), 'BigGAN:MissingWeights', ...
    'Place biggan256_initialized_V2.mat beside load_biggan.m.');
assert(~isempty(which('ONNXParameters')), 'BigGAN:MissingONNXSupport', ...
    ['Install/enable Deep Learning Toolbox Converter for ONNX Model Format ' ...
     'before loading this model.']);
s = load(file, 'net_v2');
assert(isfield(s, 'net_v2') && isa(s.net_v2, 'dlnetwork'), ...
    'BigGAN:InvalidWeights', 'Expected the initialized V2 dlnetwork net_v2.');
net = s.net_v2;
end

