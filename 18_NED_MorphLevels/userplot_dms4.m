function cond_no = userplot_dms4(TrialRecord, MLConfig)
% Psychometric curve for the morph levels: proportion of "MEI" reports.
%   MEI_k : correct / (correct + wrong)        (errors 0 / (0 + 5))
%   LEI_k : 1 - correct / (correct + wrong)    (so it is also "reported MEI")
%   Mid   : LEI_3 and MEI_3 combined (same image)
% Conditions: 1,2 = LEI_0 | 3,4 = MEI_0 | 5,6 = LEI_1 | 7,8 = MEI_1 | ... | 13,14 = LEI_3 | 15,16 = MEI_3
% Error bars: binomial standard error sqrt(p(1-p)/n)

    num_morph = 5;%4;   % LEI_0..LEI_3 / MEI_0..MEI_3 (7 morph levels); the last pair is the middle
    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;

    n_points = 2*num_morph - 1;           % LEI_0, LEI_1, LEI_2, Mid, MEI_2, MEI_1, MEI_0
    p_mei   = nan(1, n_points);
    n_valid = zeros(1, n_points);
    labels  = cell(1, n_points);

    for k = 0:num_morph-1
        lei_conds = 4*k + [1 2];
        mei_conds = 4*k + [3 4];

        lei_correct = sum(ismember(conditions, lei_conds) & errors == 0);
        lei_wrong   = sum(ismember(conditions, lei_conds) & errors == 5);
        mei_correct = sum(ismember(conditions, mei_conds) & errors == 0);
        mei_wrong   = sum(ismember(conditions, mei_conds) & errors == 5);

        if k < num_morph-1
            iL = k + 1;            % LEI_k on the left side of the plot
            iM = n_points - k;     % MEI_k on the right side
            labels{iL} = sprintf('LEI_%d', k);
            labels{iM} = sprintf('MEI_%d', k);

            n_valid(iL) = lei_correct + lei_wrong;
            if n_valid(iL) > 0
                p_mei(iL) = 1 - lei_correct / n_valid(iL);
            end

            n_valid(iM) = mei_correct + mei_wrong;
            if n_valid(iM) > 0
                p_mei(iM) = mei_correct / n_valid(iM);
            end
        else
            iMid = num_morph;      % middle (LEI_3 = MEI_3)
            labels{iMid} = 'Mid';
            n_valid(iMid) = lei_correct + lei_wrong + mei_correct + mei_wrong;
            if n_valid(iMid) > 0
                p_mei(iMid) = (mei_correct + lei_wrong) / n_valid(iMid);   % reported MEI
            end
        end
    end

    % Total performance for LEI_0 and MEI_0 (conditions 1-4)
    correct_total = sum(ismember(conditions, 1:4) & errors == 0);
    wrong_total   = sum(ismember(conditions, 1:4) & errors == 5);
    performance_total = correct_total / (correct_total + wrong_total);

    % Plot
    se = sqrt(p_mei .* (1 - p_mei) ./ n_valid);
    x = 1:n_points;
    errorbar(x, p_mei, se, 'o-', 'LineWidth', 1.5, ...
        'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410]);
    hold on
    plot([0.5 n_points+0.5], [0.5 0.5], 'k--');   % chance
    hold off

    ylim([0 1]);
    xlim([0.5 n_points+0.5]);
    xticks(x);
    xticklabels(labels);
    set(gca, 'TickLabelInterpreter', 'none');   % keep "LEI_0" from becoming a subscript
    xlabel('Morph level');
    ylabel('P(report MEI)');
    title_str = ['Total Performance %' num2str(round(performance_total*100))];
    title(title_str);
    grid on;
end