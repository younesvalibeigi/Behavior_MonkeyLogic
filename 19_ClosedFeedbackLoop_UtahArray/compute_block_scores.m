function out = compute_block_scores(FR, block_trial_log, fr_chan_exc, fr_chan_inh, NCH, N_COND, IMGS_PER_COND)
% compute_block_scores  Turn the raw FR matrix from the server into one
% score per image of the block.
%
% Inputs:
%   FR              : NCH x nTTL firing rates (spikes/s). Column k = k-th
%                     TTL (image onset) of the block, in time order.
%   block_trial_log : struct array, one entry per trial of this block, with
%                     .cond_idx, .err_code, .had_ttl, .ttl_count
%   fr_chan_exc     : 1-based row indices of excitatory channels in FR
%                     (e.g., [1 3]; [] = no excitation channels).
%                     These are NOT global electrode indices.
%   fr_chan_inh     : 1-based row indices of inhibitory channels in FR
%                     (e.g., 2; [] = no inhibition channels).
%                     These are NOT global electrode indices.
%   NCH             : number of selected channels sent by the server
%                     (e.g., 3 for A27, B18, B31; not necessarily 96).
%   N_COND          : conditions per block (5)
%   IMGS_PER_COND   : images per condition (10)
%
% Output struct:
%   scores           : 1 x 50, scores_exc - scores_inh  (what CMA-ES maximizes)
%   scores_exc       : 1 x 50, mean FR over the excitatory channel(s)
%   scores_inh       : 1 x 50, mean FR over the inhibitory channel(s)
%   FR_img           : NCH x 50, selected channels only.
%                      Rows follow the server's sorted channel order.
%                      Column j corresponds to image j of the block.
%   err_per_ttl, cond_idx_per_ttl, keep_mask : TTL bookkeeping (for checking)
%
% HOW THE ALIGNMENT WORKS
%   The server makes one FR column for EVERY TTL, including TTLs from
%   aborted trials (errors 3/4: the monkey broke fixation mid-train).
%   The userloop logged how many TTLs each trial sent (ttl_count).
%   Repeating each trial's error code ttl_count times labels every column.
%   Keeping only columns with error 0 leaves the 10 images of each completed
%   condition. Those are then put in block order (condition 1 images 1..10,
%   condition 2 images 1..10, ...), which is the order of block_image_names:
%   images 1-40 = BigGAN codes 1-40, images 41-50 = natural controls.

n_expected = N_COND * IMGS_PER_COND;
[rows, cols] = size(FR);
if rows ~= NCH
    error('compute_block_scores: FR has %d rows, expected %d channels.', rows, NCH);
end

% ---- 1) label every TTL with its trial's error code and condition ----
err_per_ttl      = zeros(1,0);
cond_idx_per_ttl = zeros(1,0);
for k = 1:numel(block_trial_log)
    tr = block_trial_log(k);
    n  = double(tr.ttl_count);
    if tr.had_ttl && ~isempty(n) && n > 0
        err_per_ttl      = [err_per_ttl,      repmat(double(tr.err_code), 1, n)]; %#ok<AGROW>
        cond_idx_per_ttl = [cond_idx_per_ttl, repmat(double(tr.cond_idx), 1, n)]; %#ok<AGROW>
    end
end
if numel(err_per_ttl) ~= cols
    error(['compute_block_scores: the server sent %d FR columns, but MonkeyLogic logged %d TTLs.\n' ...
           'Possible causes: FR_PULL_DELAY too short (last TTL not finalized yet),\n' ...
           'a missed/extra TTL, or the server buffer was not empty at session start.'], ...
           cols, numel(err_per_ttl));
end

% ---- 2) keep only TTLs from successful trials ----
keep_mask = (err_per_ttl == 0);
FR_ok     = FR(:, keep_mask);
cond_ok   = cond_idx_per_ttl(keep_mask);

% ---- 3) put the kept columns in block-image order ----
order = zeros(1, n_expected);
for c = 1:N_COND
    idx = find(cond_ok == c);
    if numel(idx) ~= IMGS_PER_COND
        error('compute_block_scores: condition %d has %d TTLs from successful trials (expected %d).', ...
              c, numel(idx), IMGS_PER_COND);
    end
    order((c-1)*IMGS_PER_COND + (1:IMGS_PER_COND)) = idx;
end
FR_img = FR_ok(:, order);          % NCH x 50, column j = image j

% % ---- 4) channel indices: 0-based IDs -> 1-based MATLAB rows ----
% rows_exc = fr_chan_exc(fr_chan_exc >= 0) + 1;   % -1 -> empty (no channel)
% rows_inh = fr_chan_inh(fr_chan_inh >= 0) + 1;
% if any(rows_exc > NCH) || any(rows_inh > NCH)
%     error('compute_block_scores: channel index out of range (must be 0..%d or -1).', NCH-1);
% end

% ---- 4) Selected channel rows in the received FR matrix ----
% fr_chan_exc and fr_chan_inh are already 1-based MATLAB row indices.
% The BigGAN userloop calculates these indices from the selected
% physical channels after sorting them into the server's A-B-C-D order.
% Do NOT add 1 or convert from global electrode indices.
% An empty array [] means no channels selected for that group.

rows_exc = fr_chan_exc;
rows_inh = fr_chan_inh;

if any(rows_exc < 1 | rows_exc > NCH) || ...
   any(rows_inh < 1 | rows_inh > NCH)
    error('compute_block_scores: channel row out of range (must be 1..%d).', NCH);
end

% ---- 5) scores ----
out.scores_exc = channel_mean(FR_img, rows_exc);
out.scores_inh = channel_mean(FR_img, rows_inh);
out.scores     = out.scores_exc - out.scores_inh;

out.FR_img           = FR_img;
out.err_per_ttl      = err_per_ttl;
out.cond_idx_per_ttl = cond_idx_per_ttl;
out.keep_mask        = keep_mask;
end

function v = channel_mean(FR_img, rows)
% Mean FR over the selected channels (zeros if no channel selected).
if isempty(rows)
    v = zeros(1, size(FR_img, 2));
else
    v = mean(FR_img(rows, :), 1);
end
end
