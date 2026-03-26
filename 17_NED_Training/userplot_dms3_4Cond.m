function cond_no = userplot_dms3_4Cond(TrialRecord, MLConfig)

    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;

    % Initialize
    performance = nan(1,4);
    fail_to_respond = nan(1,4);

    % Compute values for conditions 1 to 4
    for cond = 1:4
        cond_idx = (conditions == cond);

        % Counts for performance
        n_correct = sum(cond_idx & (errors == 0));
        n_wrong   = sum(cond_idx & (errors == 5));

        % Counts for fail to respond
        n_fail = sum(cond_idx & (errors == 6 | errors == 7));

        % Performance = 0 / (0 + 5)
        denom_perf = n_correct + n_wrong;
        if denom_perf > 0
            performance(cond) = n_correct / denom_perf;
        end

        % Fail-to-respond portion = (6 + 7) / (0 + 5 + 6 + 7)
        denom_fail = n_correct + n_wrong + n_fail;
        if denom_fail > 0
            fail_to_respond(cond) = n_fail / denom_fail;
        end
    end

    % Plot grouped bars
    data_to_plot = [performance(:), fail_to_respond(:)];
    b = bar(data_to_plot, 'grouped');

    % Optional colors
    b(1).FaceColor = [0 0.4470 0.7410];   % blue for performance
    b(2).FaceColor = [0.2 0.7 0.2];       % green for fail to respond

    ylim([0 1]);
    xlim([0.5 4.5]);
    xticks(1:4);
    xticklabels({'1','2','3','4'});
    xlabel('Condition');
    ylabel('Proportion');
    title('Performance and Fail-to-Respond by Condition');
    legend({'Performance', 'Fail to respond'}, 'Location', 'best');
    grid on;

end