
This code is wrong, do not use it.


%% make_fc6_slerp_morph.m
% Makes N Slerp morph levels between an XDream LEI and MEI (FC6 generator).
%   1) Each PNG -> FC6 code (AlexNet fc6 activations, approximate)
%   2) Slerp between the two codes (same algorithm as process_last_block_avg_slerp_v2)
%   3) Render each code with G.visualize and save as LEI_1 ... LEI_k, MEI_k ... MEI_1
%
% Naming for N = 7 (level 1 = LEI end, level 7 = MEI end):
%   level: 1      2      3      4              5      6      7
%   name : LEI_1  LEI_2  LEI_3  LEI_4 & MEI_4  MEI_3  MEI_2  MEI_1
% The middle level (odd N) is saved twice, as LEI_mid and MEI_mid (same image).

clear; clc;

%% ===== Settings =====
img_dir3 = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\17_NED_Training\synthetic_img_alexnet_relu3_2026-07-11_11-52-23';
idx_syn    = 8;                    % 54; 2; 95
N          = 7;                    % number of morph levels, including LEI and MEI
fc6_file   = 'matlabGANfc6.mat';   % FC6 generator weights
code_layer = 'fc6';                % 'fc6' or 'relu6' (pick the one that redraws better)
match_norm = true;                 % rescale codes to the norm of known-good XDream codes
ref_code_file = 'texture_init_code.mat';   % known-good FC6 codes (rows = codes)

img1 = fullfile(img_dir3, sprintf('%d_LEI.png', idx_syn));
img2 = fullfile(img_dir3, sprintf('%d_MEI.png', idx_syn));

outDir = fullfile(pwd, sprintf('%d_morph_slerp_FC6_%s', idx_syn, ...
    datestr(now, 'yyyy-mm-dd_HH-MM-SS')));
if ~exist(outDir, 'dir'), mkdir(outDir); end

%% ===== Load generator and AlexNet =====
G   = FC6Generator(fc6_file);
net = alexnet;

%% ===== 1) Image -> code =====
% Codes from MATLAB's AlexNet can be on a different scale than the codes
% this generator expects, which saturates the images (all 0 or 255).
% So each code is rescaled to the typical norm of known-good XDream codes.
target_norm = [];
if match_norm
    s = load(ref_code_file);
    fn = fieldnames(s);
    ref_codes = double(s.(fn{1}));                 % rows = codes
    target_norm = mean(vecnorm(ref_codes, 2, 2));
    fprintf('Reference code norm: %.2f\n', target_norm);
end
[z_LEI, r_LEI] = image2code(G, net, img1, code_layer, target_norm);
[z_MEI, r_MEI] = image2code(G, net, img2, code_layer, target_norm);
fprintf('Redraw similarity (%s): LEI r = %.3f | MEI r = %.3f\n', code_layer, r_LEI, r_MEI);

%% ===== 2) Slerp =====
z1 = z_LEI(:);
z2 = z_MEI(:);
fprintf('norm(z_LEI): %.4f | norm(z_MEI): %.4f\n', norm(z1), norm(z2));

cosTheta = dot(z1/norm(z1), z2/norm(z2));
cosTheta = max(min(cosTheta, 1), -1);
theta    = acos(cosTheta);
fprintf('Theta: %.4f rad | cosTheta: %.4f\n', theta, cosTheta);

alphas      = (0:N-1) / (N-1);          % 0 = LEI, 1 = MEI
morph_codes = zeros(N, numel(z1));
for k = 1:N
    a = alphas(k);
    if abs(theta) < 1e-6                % codes almost identical -> linear
        v = (1-a)*z1 + a*z2;
    else
        v = (sin((1-a)*theta)/sin(theta))*z1 + (sin(a*theta)/sin(theta))*z2;
    end
    morph_codes(k,:) = v';              % 1 x 4096
end

%% ===== 3) Render, name and save =====
names = level_names(N);                 % names{k} = file name(s) for level k
imgs  = cell(1, N);
figure('Name', sprintf('Slerp morph %d', idx_syn));
for k = 1:N
    raw     = G.visualize(morph_codes(k,:));
    fprintf('Level %d: class %s | size %s | min %.3f | max %.3f\n', k, class(raw), ...
        mat2str(size(raw)), double(min(raw(:))), double(max(raw(:))));
    img     = to_uint8(raw);
    imgs{k} = img;
    for j = 1:numel(names{k})
        outName = fullfile(outDir, [names{k}{j} '.png']);
        imwrite(img, outName);
        fprintf('Saved %s\n', outName);
    end
    subplot(1, N, k); imshow(img);
    title(strjoin(names{k}, ' / '), 'Interpreter', 'none');
end

% Keep the originals and codes next to the morphs
copyfile(img1, fullfile(outDir, 'original_LEI.png'));
copyfile(img2, fullfile(outDir, 'original_MEI.png'));
save(fullfile(outDir, 'morph_codes.mat'), 'z_LEI', 'z_MEI', 'morph_codes', ...
    'alphas', 'names', 'theta', 'code_layer', 'img1', 'img2', 'N');
fprintf('Done: %d levels in %s\n', N, outDir);


%% ===== Local functions =====
function [code, r] = image2code(G, net, png_file, code_layer, target_norm)
% PNG -> 1x4096 FC6 code via AlexNet; r = similarity of redraw to original
img = imread(png_file);
if size(img,3) == 1, img = repmat(img, [1 1 3]); end
img_in = imresize(img, net.Layers(1).InputSize(1:2));
code = activations(net, img_in, code_layer, 'OutputAs', 'rows');
code = double(code);
fprintf('%s code before scaling: mean %.3f | std %.3f | norm %.2f\n', ...
    png_file, mean(code), std(code), norm(code));
if ~isempty(target_norm)
    code = code * (target_norm / norm(code));
end

rec = to_uint8(G.visualize(code));
ref = imresize(img, [size(rec,1) size(rec,2)]);
r   = corr(double(rec(:)), double(ref(:)));
end

function names = level_names(N)
% Level 1 = LEI_1, level N = MEI_1; middle level (odd N) gets both names
names = cell(1, N);
for k = 1:N
    fromLEI = k;            % LEI_1, LEI_2, ...
    fromMEI = N - k + 1;    % ..., MEI_2, MEI_1
    if fromLEI == fromMEI
        names{k} = {sprintf('LEI_%d', fromLEI), sprintf('MEI_%d', fromMEI)};
    elseif fromLEI < fromMEI
        names{k} = {sprintf('LEI_%d', fromLEI)};
    else
        names{k} = {sprintf('MEI_%d', fromMEI)};
    end
end
end

function img = to_uint8(img)
% Generator output -> uint8 for imwrite
if isa(img, 'uint8'), return; end
img = double(img);
if max(img(:)) <= 1
    img = uint8(255 * img);
else
    img = uint8(img);
end
end