%% make_morph_levels.m
% Loads the MEI/LEI latent codes of one neuron (N_codes.mat), makes n morph
% levels between them with Slerp, renders each with BigGAN, and saves PNGs as
%   LEI_0, LEI_1, ..., LEI_mid, MEI_mid, ..., MEI_1, MEI_0
% LEI_0 = original LEI, MEI_0 = original MEI. With odd n, LEI_mid and MEI_mid
% are the same middle image (LEI_4 = MEI_4 when n = 9).
% Output folder: yymmdd_<label>_HHMM_morphs_<N>_n<n_levels>, where <label> is
% the next free letter (a, b, c, ...) among today's folders.
clear; clc;
%% ---------------- Settings ----------------
N          = 2;    % neuron / image number -> 32_codes.mat
n_levels   = 9;     % number of morph levels (incl. both endpoints)
%codeFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\18_NED_MorphLevels\synthetic_img_biggan_alexnet_conv3_2026-10-15_16-45-57';
codeFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\NIMHMonkeyLogic20x2E4@2.4.2\task\Behavior_MonkeyLogic\18_NED_MorphLevels\synthetic_img_biggan_robustR50_layer3_0_2026-11-08_15-26-00';
bigganFolder = codeFolder;  % folder containing load_biggan.m / generate_biggan.m (change if elsewhere)

%% ---------------- Output folder: yymmdd_<label>_HHMM_<name> ----------------
nowDT    = datetime('now');
dateStr  = char(nowDT, 'yyMMdd');    % e.g. 261021
timeStr  = char(nowDT, 'HHmm');      % e.g. 1645
baseName = sprintf('morphs_%d_n%d', N, n_levels);

% Find labels already used today (files or folders named yymmdd_<letter>_...)
existing = dir(fullfile(pwd, [dateStr '_*']));
used = '';
for i = 1:numel(existing)
    tok = regexp(existing(i).name, ['^' dateStr '_([a-z])_'], 'tokens', 'once');
    if ~isempty(tok), used(end+1) = tok{1}; end %#ok<AGROW>
end
if isempty(used)
    label = 'a';
else
    label = char(max(used) + 1);
end
if label > 'z'
    error('All labels a-z are already used for %s.', dateStr);
end

outFolder = fullfile(pwd, sprintf('%s_%s_%s_%s', dateStr, label, timeStr, baseName));
mkdir(outFolder);
fprintf('Output folder: %s\n', outFolder);

%% ---------------- Load codes ----------------
S = load(fullfile(codeFolder, sprintf('%d_codes.mat', N)));
if isfield(S, 'z_MEI')                    % robust ResNet-50 / single-neuron BigGAN scripts
    mei_code = double(S.z_MEI(:)');
    lei_code = double(S.z_LEI(:)');
elseif isfield(S, 'mei_code')             % older BigGAN codes files
    mei_code = double(S.mei_code(:)');
    lei_code = double(S.lei_code(:)');
else
    error('No MEI/LEI codes found in %d_codes.mat. Variables: %s', N, strjoin(fieldnames(S), ', '));
end
%% ---------------- Load BigGAN ----------------
addpath(bigganFolder);
G = load_biggan();
%% ---------------- Morph levels ----------------
%t   = linspace(0, 1, n_levels);    % 0 = LEI, 1 = MEI
%t = [0, 0.15, 0.30, 0.40, 0.50, 0.60, 0.70, 0.85, 1];
t = [0, 0.08, 0.18, 0.32, 0.50, 0.68, 0.82, 0.92, 1];
mid = ceil(n_levels/2);            % 5 when n = 9
levelNames = strings(n_levels, 1); % file name(s) for each level, for the log
for k = 1:n_levels
    fprintf('Level %d/%d (t = %.3f)\n', k, n_levels, t(k));
    code = slerp(lei_code, mei_code, t(k));
    img  = to_rgb01(generate_biggan(G, code));
    % File name(s)
    names = {};
    if k <= mid,                names{end+1} = sprintf('LEI_%d', k - 1); end          %#ok<SAGROW>
    if k >= n_levels - mid + 1, names{end+1} = sprintf('MEI_%d', n_levels - k); end   %#ok<SAGROW>
    for j = 1:numel(names)
        imwrite(img, fullfile(outFolder, [names{j} '.png']));
    end
    levelNames(k) = strjoin(names, ' / ');
end

%% ---------------- Save the t values ----------------
T = table((1:n_levels)', t(:), levelNames, 'VariableNames', {'level', 't', 'file'});
writetable(T, fullfile(outFolder, 'morph_levels.csv'));
save(fullfile(outFolder, 'morph_levels.mat'), 't', 'T', 'N', 'n_levels', 'lei_code', 'mei_code');

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