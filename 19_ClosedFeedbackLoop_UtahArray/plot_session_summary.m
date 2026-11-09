function plot_session_summary(img_traj, generations, scores_all, img_type_all, outdir_abs)
% plot_session_summary  End-of-session figures, saved as .png AND .fig.
%
% WAYS TO USE IT (figures are saved in the session's folder)
%   plot_session_summary()                          -> (or press Run) pick the file in a window
%   plot_session_summary('session_all.mat')         -> file in the current folder
%   plot_session_summary('C:\...\session_all.mat')  -> full path to the file
%   plot_session_summary('C:\...\<session folder>') -> folder of a session
%   plot_session_summary(img_traj, generations, scores_all, img_type_all, outdir)
%                                                   -> how the userloops call it
%
% OLDER XDREAM SESSIONS are also accepted: folders with separate
% scores_all.mat, generations.mat, img_traj.mat (no session_all.mat).
% Pick or pass scores_all.mat, or the session folder. img_type_all is then
% rebuilt from the block structure: in each block the first 40 rows are
% synthetic images and any rows after them are natural controls.
%
% Figures:
%   1) montage of the block representative images (mean code per block)
%   2) scores by block: every synthetic image (gray), synthetic mean (black),
%      natural-control mean (red)
% The numbers behind figure 2 are also saved in session_summary_data.mat.
%
% scores_all column 1 = score (exc - inh); img_type_all: 0 = synthetic, 1 = natural

IMGS_PER_BLOCK_OLD = 40;   % synthetic images per block in the older XDream sessions

% ---- 0) no data given: load a session (new or older format) ----
if nargin <= 1
    if nargin == 0
        [fname, fpath] = uigetfile({'session_all.mat;scores_all.mat', ...
            'session_all.mat or scores_all.mat (older XDream)'}, 'Choose a session file');
        if isequal(fname, 0)
            disp('No file chosen.');
            return
        end
        target = fullfile(fpath, fname);
    else
        target = char(img_traj);                    % the single input is a path
        % relative name (e.g. 'session_all.mat') -> path in the current folder
        isAbsolute = ~isempty(regexp(target, '^([A-Za-z]:|\\\\|/)', 'once'));
        if ~isAbsolute
            target = fullfile(pwd, target);
        end
    end
    [img_traj, generations, scores_all, img_type_all, outdir_abs] = ...
        load_session(target, IMGS_PER_BLOCK_OLD);
end

reps = {};

% ---- 1) trajectory montage ----
try
    reps = img_traj(~cellfun(@isempty, img_traj));
    if ~isempty(reps)
        f1 = figure('Name', 'Block representatives');
        montage(reps);
        title('Block representatives (generator output of the mean code)');
        exportgraphics(f1, fullfile(outdir_abs, 'block_representatives.png'));
        savefig(f1, fullfile(outdir_abs, 'block_representatives.fig'));
    end
catch ME
    warning('plot_session_summary (montage): %s', ME.message);
end

% ---- 2) scores by block ----
try
    if isempty(scores_all), return; end
    syn = (img_type_all == 0);
    nat = (img_type_all == 1);
    blocks = unique(generations);
    m_syn   = arrayfun(@(b) mean(scores_all(generations == b & syn, 1)), blocks);
    max_syn = arrayfun(@(b) max(scores_all(generations == b & syn, 1)),  blocks);
    m_nat   = arrayfun(@(b) mean(scores_all(generations == b & nat, 1)), blocks);

    f2 = figure('Name', 'Scores by block'); hold on; box on;
    scatter(generations(syn), scores_all(syn, 1), 12, [0.6 0.6 0.6], 'filled');
    plot(blocks, m_syn, 'k-', 'LineWidth', 2);
    if any(nat)
        plot(blocks, m_nat, 'r-', 'LineWidth', 2);
        legend('synthetic (each image)', 'synthetic mean', 'natural mean', 'Location', 'best');
    else
        legend('synthetic (each image)', 'synthetic mean', 'Location', 'best');
    end
    xlabel('Block (generation)');
    ylabel('Score = FR_{exc} - FR_{inh} (spikes/s)');
    title('Scores by block');
    exportgraphics(f2, fullfile(outdir_abs, 'scores_by_block.png'));
    savefig(f2, fullfile(outdir_abs, 'scores_by_block.fig'));

    % Numbers behind the figures, for later analysis
    block_reps = reps; %#ok<NASGU>   % representative image of each block (cell)
    save(fullfile(outdir_abs, 'session_summary_data.mat'), ...
         'blocks', 'm_syn', 'max_syn', 'm_nat', 'block_reps', 'img_type_all');
    fprintf('Figures (.png, .fig) and session_summary_data.mat saved in %s\n', outdir_abs);
catch ME
    warning('plot_session_summary (scores): %s', ME.message);
end
end

%% ------------------------------------------------------------------------
function [img_traj, generations, scores_all, img_type_all, folder] = load_session(target, nSynOld)
% Load a session from a session_all.mat, a scores_all.mat (older XDream
% format) or a session folder containing either.

if isfolder(target)
    folder = target;
    if isfile(fullfile(folder, 'session_all.mat'))
        target = fullfile(folder, 'session_all.mat');
    elseif isfile(fullfile(folder, 'scores_all.mat'))
        target = fullfile(folder, 'scores_all.mat');
    else
        error('plot_session_summary: no session_all.mat or scores_all.mat in %s', folder);
    end
end
if ~isfile(target)
    error('plot_session_summary: file not found: %s', target);
end
[folder, name] = fileparts(target);

if strcmpi(name, 'session_all')
    % ---- new format: everything in one file ----
    S = load(target, 'img_traj', 'generations', 'scores_all', 'img_type_all');
    img_traj     = S.img_traj;
    generations  = S.generations;
    scores_all   = S.scores_all;
    img_type_all = S.img_type_all;
    fprintf('Loaded %s\n', target);
else
    % ---- older XDream format: separate files ----
    need = {'scores_all', 'generations', 'img_traj'};
    for k = 1:numel(need)
        if ~isfile(fullfile(folder, [need{k} '.mat']))
            error('plot_session_summary: %s.mat missing in %s (older format needs scores_all, generations, img_traj).', ...
                  need{k}, folder);
        end
    end
    s1 = load(fullfile(folder, 'scores_all.mat'),  'scores_all');
    s2 = load(fullfile(folder, 'generations.mat'), 'generations');
    s3 = load(fullfile(folder, 'img_traj.mat'),    'img_traj');
    scores_all  = s1.scores_all;
    generations = s2.generations(:);
    img_traj    = s3.img_traj;

    % Rebuild img_type_all: in each block, rows 1..nSynOld are synthetic,
    % any rows after them are natural controls
    img_type_all = zeros(size(generations));
    for b = unique(generations)'
        rows = find(generations == b);
        img_type_all(rows(nSynOld+1:end)) = 1;
    end
    fprintf('Loaded older XDream session in %s\n', folder);
    fprintf('  img_type_all rebuilt: first %d images of each block = synthetic, the rest = natural (%d natural rows)\n', ...
            nSynOld, sum(img_type_all));
end
end