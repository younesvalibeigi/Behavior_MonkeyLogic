%% make_morph_levels.m
% Loads the MEI/LEI latent codes of one neuron (N_codes.mat), makes n morph
% levels between them with Slerp, renders each with BigGAN, and saves PNGs as
%   LEI_0, LEI_1, ..., LEI_mid, MEI_mid, ..., MEI_1, MEI_0
% LEI_0 = original LEI, MEI_0 = original MEI. With odd n, LEI_mid and MEI_mid
% are the same middle image (LEI_3 = MEI_3 when n = 7).

clear; clc;

%% ---------------- Settings ----------------
N          = 32;    % neuron / image number -> 48_codes.mat
n_levels   = 7;     % number of morph levels (incl. both endpoints)
codeFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\18_NED_MorphLevels\synthetic_img_biggan_alexnet_conv3_2026-10-15_16-45-57';
bigganFolder = codeFolder;  % folder containing load_biggan.m / generate_biggan.m (change if elsewhere)

% Output folder, created inside the current MATLAB folder
outFolder = fullfile(pwd, sprintf('morphs_%d_n%d', N, n_levels));
if ~exist(outFolder, 'dir'), mkdir(outFolder); end

%% ---------------- Load codes ----------------
S = load(fullfile(codeFolder, sprintf('%d_codes.mat', N)), 'mei_code', 'lei_code');
lei_code = double(S.lei_code(:)');   % 1x256 (128 noise + 128 class)
mei_code = double(S.mei_code(:)');   % 1x256

%% ---------------- Load BigGAN ----------------
addpath(bigganFolder);
G = load_biggan();

%% ---------------- Morph levels ----------------
t = linspace(0, 1, n_levels);    % 0 = LEI, 1 = MEI
mid = ceil(n_levels/2);          % 4 when n = 7

for k = 1:n_levels
    fprintf('Level %d/%d (t = %.3f)\n', k, n_levels, t(k));

    code = slerp(lei_code, mei_code, t(k));
    img  = to_rgb01(generate_biggan(G, code));

    % File name(s)
    names = {};
    if k <= mid,               names{end+1} = sprintf('LEI_%d', k - 1); end          %#ok<SAGROW>
    if k >= n_levels - mid + 1, names{end+1} = sprintf('MEI_%d', n_levels - k); end     %#ok<SAGROW>

    for j = 1:numel(names)
        imwrite(img, fullfile(outFolder, [names{j} '.png']));
    end
end

fprintf('Done. Saved to:\n%s\n', outFolder);

%% ---------------- Helper functions ----------------
function c = slerp(a, b, t)
% Spherical interpolation on the full (unnormalized) code vector.
    omega = acos( max(-1, min(1, dot(a/norm(a), b/norm(b)))) );
    if abs(sin(omega)) < 1e-6           % nearly parallel -> linear
        c = (1-t)*a + t*b;
    else
        c = (sin((1-t)*omega)*a + sin(t*omega)*b) / sin(omega);
    end
end

function img = to_rgb01(img)
% Converts generator output to H x W x 3 in [0, 1] for imwrite.
    img = double(gather(squeeze(img)));
    if size(img,1) == 3 && size(img,3) ~= 3
        img = permute(img, [2 3 1]);      % 3xHxW -> HxWx3
    end
    if min(img(:)) < 0                    % BigGAN-style [-1, 1]
        img = (img + 1) / 2;
    elseif max(img(:)) > 1                % [0, 255]
        img = img / 255;
    end
    img = min(max(img, 0), 1);
end