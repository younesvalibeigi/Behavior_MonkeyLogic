function cond_no = userplot_Scores(TrialRecord, MLConfig)
    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;
    num_completeCond = length(find(errors==0));
    scores_all = TrialRecord.User.scores_all;
    generations = TrialRecord.User.generations;
    IMGS_PER_BLOCK = TrialRecord.User.IMGS_PER_BLOCK;
    NatIMGS_PER_BLOCK = TrialRecord.User.NatIMGS_PER_BLOCK;
    
    nGen = max(generations);

    avg_gen = nan(1,nGen);
    se_gen  = nan(1,nGen);
    avg_nat = nan(1,nGen);
    se_nat  = nan(1,nGen);
    pvals   = nan(1,nGen);
    
    for ii = 1:nGen
        idx = find(generations == ii);
    
        % get gen and nat scores
        scores_genImg = scores_all(idx(1:IMGS_PER_BLOCK));
        scores_natImg = scores_all(idx(IMGS_PER_BLOCK+1 : IMGS_PER_BLOCK+NatIMGS_PER_BLOCK));
    
        % averages + SE
        avg_gen(ii) = mean(scores_genImg);
        se_gen(ii)  = std(scores_genImg) / sqrt(length(scores_genImg));
    
        avg_nat(ii) = mean(scores_natImg);
        se_nat(ii)  = std(scores_natImg) / sqrt(length(scores_natImg));
    
        % Welch's t-test
        [~,pvals(ii)] = ttest2(scores_genImg, scores_natImg, 'Vartype','unequal');
    end
    
    %figure; 
    %hold on;
    
    % Plot with error bars
    errorbar(1:nGen, avg_gen, se_gen, 'o-r','LineWidth',1.5,'MarkerFaceColor','r');
    hold on;
    errorbar(1:nGen, avg_nat, se_nat, 'o-b','LineWidth',1.5,'MarkerFaceColor','b');
    
    xlabel('Generation');
    ylabel('Average Score');
    title('Generated vs Natural Images');
    legend({'Generated','Natural'});
    grid on;
    
    % Add significance stars above red curve
    ymax = max([avg_gen+se_gen, avg_nat+se_nat]) * 1.1; % top for placing stars
    for ii = 1:nGen
        if pvals(ii) < 0.001
            stars = '***';
        elseif pvals(ii) < 0.01
            stars = '**';
        elseif pvals(ii) < 0.05
            stars = '*';
        else
            stars = '';
        end
        if ~isempty(stars)
            text(ii, avg_gen(ii) + se_gen(ii) + 0.05*range([avg_gen avg_nat]), ...
                stars, 'HorizontalAlignment','center','Color','k','FontSize',12);
        end
    end
    hold off;

end % == end of function