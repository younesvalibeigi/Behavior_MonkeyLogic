function cond_no = userplot_dms3_4Cond_progress(TrialRecord, MLConfig)
    conditions = TrialRecord.ConditionsPlayed;
    errors     = TrialRecord.TrialErrors;
    n_trials   = numel(conditions);

    % Colors for conditions 1-4
    colors = [0      0.4470 0.7410;   % blue
              0.8500 0.3250 0.0980;   % orange
              0.9290 0.6940 0.1250;   % yellow
              0.4940 0.1840 0.5560]; % purple
    total_color = [0 0 0]; % black

    hold on;
    legend_entries = {};

    % --- Per-condition cumulative performance curves ---
    for cond = 1:4
        cond_idx = find(conditions == cond & (errors == 0 | errors == 5));
        if isempty(cond_idx)
            continue;
        end

        correct      = (errors(cond_idx) == 0);
        cum_correct  = cumsum(correct);
        cum_n        = 1:numel(cond_idx);
        perf_curve   = cum_correct ./ cum_n;

        plot(cond_idx, perf_curve, 'Color', colors(cond,:), 'LineWidth', 1.5);
        legend_entries{end+1} = ['Cond ' num2str(cond)];
    end

    % --- Overall (total) cumulative performance curve ---
    valid_idx     = find(errors == 0 | errors == 5);
    correct_all   = (errors(valid_idx) == 0);
    cum_correct_a = cumsum(correct_all);
    cum_n_all     = 1:numel(valid_idx);
    perf_all      = cum_correct_a ./ cum_n_all;

    plot(valid_idx, perf_all, 'Color', total_color, 'LineWidth', 2, 'LineStyle', '--');
    legend_entries{end+1} = 'Total';

    % --- Formatting ---
    ylim([0 1]);
    xlim([1 max(n_trials, 2)]);
    xlabel('Trial Number');
    ylabel('Cumulative Performance');
    title('Performance Progress Over Trials');
    legend(legend_entries, 'Location', 'best');
    grid on;
    hold off;
end