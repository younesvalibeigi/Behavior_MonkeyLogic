%% make_cirRad_morph_levels.m
% Makes n morph levels between cir0.png (LEI) and rad0.png (MEI) with the
% XDream pixel-space technique (Slerp or linear on the flattened pixels),
% and saves PNGs as
%   LEI_0, LEI_1, ..., LEI_mid, MEI_mid, ..., MEI_1, MEI_0
% LEI_0 = original cir0 (circular), MEI_0 = original rad0 (radial).
% With odd n, LEI_mid and MEI_mid are the same middle image (LEI_4 = MEI_4 when n = 9).
% Output folder (in the current MATLAB folder):
%   yymmdd_<label>_HHMM_morphs_cirRad_n<n_levels>
% where <label> is the next free letter (a, b, c, ...) among today's folders.
clear; clc;

%% ---------------- Settings ----------------
n_levels  = 9;      % number of morph levels (incl. both endpoints)
useSlerp  = true;   % true = Slerp (XDream slerp), false = linear blend
srcFolder = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\15_RFmap_stimShow_DMS_DiffLatency\stimulus';
leiName   = 'cir0.png';   % LEI = circular
meiName   = 'rad0.png';   % MEI = radial

%% ---------------- Output folder: yymmdd_<label>_HHMM_<name> ----------------
nowDT    = datetime('now');
dateStr  = char(nowDT, 'yyMMdd');    % e.g. 261022
timeStr  = char(nowDT, 'HHmm');      % e.g. 1645
baseName = sprintf('morphs_cirRad_n%d', n_levels);

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

%% ---------------- Load images ----------------
lei_img = imread(fullfile(srcFolder, leiName));
mei_img = imread(fullfile(srcFolder, meiName));
if ~isequal(size(lei_img), size(mei_img))
    error('%s and %s must be the same size (got %s vs %s).', leiName, meiName, ...
        mat2str(size(lei_img)), mat2str(size(mei_img)));
end
imgSize = size(lei_img);
lei_vec = double(lei_img(:));   % flattened pixels
mei_vec = double(mei_img(:));

%% ---------------- Morph levels ----------------
%t   = linspace(0, 1, n_levels);    % 0 = LEI (cir), 1 = MEI (rad)
%t = [0, 0.15, 0.30, 0.40, 0.50, 0.60, 0.70, 0.85, 1];
t = [0, 0.08, 0.18, 0.32, 0.50, 0.68, 0.82, 0.92, 1];

mid = ceil(n_levels/2);            % 5 when n = 9
levelNames = strings(n_levels, 1); % file name(s) for each level, for the log
figure('Name', 'cir -> rad morph levels');
for k = 1:n_levels
    fprintf('Level %d/%d (t = %.3f)\n', k, n_levels, t(k));
    if useSlerp
        v = slerp(lei_vec, mei_vec, t(k));
    else
        v = (1 - t(k))*lei_vec + t(k)*mei_vec;
    end
    img = uint8(reshape(v, imgSize));   % uint8 clips to [0, 255]

    % File name(s)
    names = {};
    if k <= mid,                names{end+1} = sprintf('LEI_%d', k - 1); end          %#ok<SAGROW>
    if k >= n_levels - mid + 1, names{end+1} = sprintf('MEI_%d', n_levels - k); end   %#ok<SAGROW>
    for j = 1:numel(names)
        imwrite(img, fullfile(outFolder, [names{j} '.png']));
    end
    levelNames(k) = strjoin(names, ' / ');

    % Preview
    subplot(1, n_levels, k);
    imshow(img);
    title(sprintf('%s\nt=%.2f', levelNames(k), t(k)), 'Interpreter', 'none', 'FontSize', 7);
end

%% ---------------- Save the morph (t) values ----------------
if useSlerp, method = "slerp"; else, method = "linear"; end
T = table((1:n_levels)', t(:), levelNames, repmat(method, n_levels, 1), ...
    'VariableNames', {'level', 't', 'file', 'method'});
writetable(T, fullfile(outFolder, 'morph_levels.csv'));
save(fullfile(outFolder, 'morph_levels.mat'), 't', 'T', 'n_levels', 'method', ...
    'leiName', 'meiName', 'srcFolder');

fprintf('Done. Saved to:\n%s\n', outFolder);

%% ---------------- Helper functions ----------------
function c = slerp(a, b, t)
% Spherical interpolation on the full (unnormalized) pixel vector.
    omega = acos( max(-1, min(1, dot(a/norm(a), b/norm(b)))) );
    if abs(sin(omega)) < 1e-6           % nearly parallel -> linear
        c = (1-t)*a + t*b;
    else
        c = (sin((1-t)*omega)*a + sin(t*omega)*b) / sin(omega);
    end
end