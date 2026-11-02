function plot_session_summary(img_traj, generations, scores_all, img_type_all, outdir_abs)
% plot_session_summary  End-of-session figures, also saved as PNGs:
%   1) montage of the block representative images (mean code per block)
%   2) scores by block: every synthetic image (gray), synthetic mean (black),
%      natural-control mean (red)
%
% scores_all column 1 = score (exc - inh); img_type_all: 0 = synthetic, 1 = natural

% ---- 1) trajectory montage ----
try
    reps = img_traj(~cellfun(@isempty, img_traj));
    if ~isempty(reps)
        f1 = figure('Name', 'Block representatives');
        montage(reps);
        title('Block representatives (BigGAN of the mean code)');
        exportgraphics(f1, fullfile(outdir_abs, 'block_representatives.png'));
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
    m_syn = arrayfun(@(b) mean(scores_all(generations == b & syn, 1)), blocks);
    m_nat = arrayfun(@(b) mean(scores_all(generations == b & nat, 1)), blocks);

    f2 = figure('Name', 'Scores by block'); hold on; box on;
    scatter(generations(syn), scores_all(syn, 1), 12, [0.6 0.6 0.6], 'filled');
    plot(blocks, m_syn, 'k-', 'LineWidth', 2);
    plot(blocks, m_nat, 'r-', 'LineWidth', 2);
    legend('synthetic (each image)', 'synthetic mean', 'natural mean', 'Location', 'best');
    xlabel('Block (generation)');
    ylabel('Score = FR_{exc} - FR_{inh} (spikes/s)');
    title('Scores by block');
    exportgraphics(f2, fullfile(outdir_abs, 'scores_by_block.png'));
catch ME
    warning('plot_session_summary (scores): %s', ME.message);
end
end
