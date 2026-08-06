function cond_no = userplot_dms3_4Cond(TrialRecord, MLConfig)

    window_n = 50;

    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;

    % Initialize
    performance = nan(1,4);
    performance_lastN = nan(1,4);
    fail_to_respond = nan(1,4);
    correct_total = 0;
    wrong_total = 0;

    % Compute values for conditions 1 to 4
    for cond = 1:4
        cond_idx = (conditions == cond);
        % Last 20 valid trials for this condition (only errors 0 or 5)
        valid_idx = find(cond_idx & (errors == 0 | errors == 5));
        lastN_idx = valid_idx(max(1,end-(window_n-1)):end);
        
        if ~isempty(lastN_idx)
            n_correct_lastN = sum(errors(lastN_idx) == 0);
            n_wrong_lastN   = sum(errors(lastN_idx) == 5);
            denom_lastN = n_correct_lastN + n_wrong_lastN;
        
            if denom_lastN > 0
                performance_lastN(cond) = n_correct_lastN / denom_lastN;
            end
        end

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
        % cacluate total perfoamnce
        correct_total = correct_total + n_correct;
        wrong_total = wrong_total + n_wrong;
    end
    
    % Total perfoamnce
    performance_total = correct_total / (correct_total + wrong_total);
    % Plot grouped bars
    data_to_plot = [performance(:), performance_lastN(:), fail_to_respond(:)];
    b = bar(data_to_plot, 'grouped');

    % Optional colors
    b(1).FaceColor = [0 0.4470 0.7410];   % blue = overall performance
    b(2).FaceColor = [1 0 0];             % red = last 20 valid trials performance
    b(3).FaceColor = [0.2 0.7 0.2];       % green = fail to respond

    ylim([0 1]);
    xlim([0.5 4.5]);
    xticks(1:4);
    xticklabels({'1','2','3','4'});
    xlabel('Condition');
    ylabel('Proportion');
    title_str = ['Total Performance %' num2str(round(performance_total*100))];
    title(title_str);
    legend_2 = ['PerLast' num2str(window_n)];
    legend({'Per', legend_2, 'F'}, 'Location', 'best');
    grid on;

end