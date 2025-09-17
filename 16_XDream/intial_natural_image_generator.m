grab_100_natural_png()
function NAMES = grab_100_natural_png(outdir, save_images_mat)
% grab_100_natural_png  Download 100 natural PNGs and save locally.
% Usage:
%   NAMES = grab_100_natural_png();                     % saves to ./stim_images
%   NAMES = grab_100_natural_png('stim_images', true);  % also writes images.mat
%
% Output:
%   NAMES : cellstr of absolute file paths for the 100 saved PNGs.
%
% Source dataset: DIV2K validation HR (0801–0900), 100 PNG images.

if nargin < 1 || isempty(outdir), outdir = 'natural_images'; end
if nargin < 2, save_images_mat = true; end
if ~exist(outdir,'dir'), mkdir(outdir); end

% 1) Download the official DIV2K valid HR zip (contains 100 PNGs).
div2k_url  = 'https://data.vision.ee.ethz.ch/cvl/DIV2K/DIV2K_valid_HR.zip';
zip_path   = fullfile(tempdir, 'DIV2K_valid_HR.zip');
unz_dir    = fullfile(tempdir, 'DIV2K_valid_HR_unz');

fprintf('Downloading DIV2K_valid_HR.zip ...\n');
try
    websave(zip_path, div2k_url);
catch ME
    error('Failed to download DIV2K_valid_HR.zip: %s', ME.message);
end

% 2) Unzip to a temp folder (clean if it exists).
if exist(unz_dir,'dir'), rmdir(unz_dir,'s'); end
filelist = unzip(zip_path, unz_dir);

% 3) Find all PNGs, pick 100 at random (the set has exactly 100).
pngs = dir(fullfile(unz_dir, '**', '*.png'));
if numel(pngs) < 100
    error('Expected ~100 PNGs in DIV2K valid HR, found %d.', numel(pngs));
end
sel = randperm(numel(pngs), 100);

% 4) Copy to outdir with standardized names nat_001.png ... nat_100.png
codes = zeros(100, 4096);

NAMES = cell(100,1);
for i = 1:100
    i
    src = fullfile(pngs(sel(i)).folder, pngs(sel(i)).name);
    dst = fullfile(outdir, sprintf('nat_%03d.png', i));
    %copyfile(src, dst);
    % --- instead of copyfile(src,dst) ---
    img    = imread(src);                         % read original
    small  = imresize(img, [256 256], 'bicubic'); % resize to 256x256 (or [128 128], etc.)
    imwrite(small, dst);                          % save downsized image

    NAMES{i} = dst;
    % img = imread(src);
    % 
    % small = imresize(img, [64 64], 'bicubic');     % img is already grayscale uint8
    % codes(i,:) = reshape(double(small)/255, 1, 4096);

end

% ---- derive a 1x4096 code from the grayscale image ----
% Resize to 64x64 and flatten to a row vector in [0,1]

        

% 5) Optionally save images.mat with NAMES (relative paths are fine too)
if save_images_mat
    save(fullfile(pwd,'natural_images.mat'), 'NAMES', '-v7');
    fprintf('Saved images.mat with NAMES (%d entries).\n', numel(NAMES));
end

fprintf('Done. Wrote 100 PNGs to %s\n', outdir);
end
