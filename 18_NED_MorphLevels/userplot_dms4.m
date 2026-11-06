
function cond_no = userplot_dms4(TrialRecord, MLConfig)
% Psychometric curve: proportion of "MEI" reports.
%   MEI_k : correct / (correct + wrong)
%   LEI_k : 1 - correct / (correct + wrong)
%   Mid   : LEI_4 and MEI_4 combined (same image)
% Error bars: binomial standard error sqrt(p(1-p)/n)

    num_morph = 5;   % 9 levels: LEI_0..LEI_4 / MEI_0..MEI_4

    % Load actual morph or noise levels
    levelFile = 'C:\Users\yvalib\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\18_NED_MorphLevels\261105_e_1558_morphs_cirRad_n9\morph_levels.mat'; % or noise_levels.mat
    S = load(levelFile);

    if isfield(S, 't')
        x = S.t(:)';
        xLabelText = 'Morph level';
    elseif isfield(S, 'p')
        p = S.p(:)';
        x = [S.p(1:end-1)-1, 0, 1-fliplr(p(1:end-1))];
        xLabelText = 'Signed signal fraction (LEI to MEI)';
    else
        error('File must contain t (morph) or p (noise).');
    end

    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;

    n_points = 2*num_morph - 1;
    if numel(x) ~= n_points
        error('Number of stimulus levels does not match num_morph.');
    end

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
            iL = k + 1;
            iM = n_points - k;
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
            iMid = num_morph;
            labels{iMid} = 'Mid';
            n_valid(iMid) = lei_correct + lei_wrong + mei_correct + mei_wrong;
            if n_valid(iMid) > 0
                p_mei(iMid) = (mei_correct + lei_wrong) / n_valid(iMid);
            end
        end
    end

    % Total performance for LEI_0 and MEI_0 (conditions 1-4)
    correct_total = sum(ismember(conditions, 1:4) & errors == 0);
    wrong_total   = sum(ismember(conditions, 1:4) & errors == 5);
    performance_total = correct_total / (correct_total + wrong_total);

    % Plot
    se = sqrt(p_mei .* (1 - p_mei) ./ n_valid);
    errorbar(x, p_mei, se, 'o-', 'LineWidth', 1.5, ...
        'Color', [0 0.4470 0.7410], 'MarkerFaceColor', [0 0.4470 0.7410]);
    hold on
    plot([min(x) max(x)], [0.5 0.5], 'k--');
    hold off

    ylim([0 1]);
    xlim([min(x)-0.05 max(x)+0.05]);
    xticks(x);
    xticklabels(labels);
    xtickangle(45);
    set(gca, 'TickLabelInterpreter', 'none');
    xlabel(xLabelText);
    ylabel('P(report MEI)');
    title_str = ['Total Performance %' num2str(round(performance_total*100))];
    title(title_str);
    grid on;
end
