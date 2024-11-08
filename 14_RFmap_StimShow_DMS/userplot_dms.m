function cond_no = userplot_dms(TrialRecord, MLConfig)
    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;
    num_levels = 7;
    num_sets = 3;
    N=num_levels*4*num_sets;
    cond_set = 1:N;
    performance = 0;
    anal_range = N*2;
    freqs = ones(1,N)*2;
    indices_played = find(errors == 0 | errors == 5);
    num_toAnal = floor(length(indices_played)/anal_range)*anal_range;
    
    if mod(length(indices_played), anal_range)==0
        %disp([num2str(floor(length(indices_played)/anal_range)) '  point of analysis'])

    end
    cond_played = conditions(indices_played);
    error_played = errors(indices_played);


        
    
    sum_error_correct = zeros(2,N/4); % first row is cir second is rad over six levels
    sum_error_wrong= zeros(2,N/4);
    for i=1:num_levels*num_sets % we go for six levels
        indices_cir_correct = find((cond_played==(i-1)*4+1 | cond_played==(i-1)*4+2) & error_played==0);
        sum_error_correct(1, i) = length(indices_cir_correct);
        indices_cir_wrong = find((cond_played==(i-1)*4+1 | cond_played==(i-1)*4+2) & error_played==5);
        sum_error_wrong(1, i) = length(indices_cir_wrong);

        indices_rad_correct = find((cond_played==(i-1)*4+3 | cond_played==(i-1)*4+4) & error_played==0);
        sum_error_correct(2, i) = length(indices_rad_correct);
        indices_rad_wrong = find((cond_played==(i-1)*4+3 | cond_played==(i-1)*4+4) & error_played==5);
        sum_error_wrong(2, i) = length(indices_rad_wrong);
        
    end
    %sum_error_correct
    %sum_error_wrong
    performance = sum_error_correct ./(sum_error_correct+sum_error_wrong);
%     if N==24
%         disp_performance = [(1-performance(1,:)) flip(performance(2,:))];
%         plot(disp_performance, 'b-o', 'DisplayName', 'Ctrl');
%         xlabel('cir-rad');
%         ylabel('radial response');
%         title('Performance Plot');
%         grid on;
%     elseif N==48
%         midPoint = num_levels;
%         disp_performance_ctrl = [(1-performance(1,1:midPoint)) flip(performance(2,1:midPoint))];
%         plot(disp_performance_ctrl, 'b-o', 'DisplayName', 'Ctrl');
%         disp_performance_Mrstm = [(1-performance(1,midPoint+1:N/4)) flip(performance(2,midPoint+1:N/4))];
%         hold on,
%         plot(disp_performance_Mrstm, 'r-o', 'DisplayName', 'Mrstm');
%         hold off;
%         xlabel('cir-rad');
%         ylabel('radial response');
%         title('Performance Plot');
%     end
    
    color = {'k-o', 'b-o', 'r-o', 'y-o', 'g-o'};    
    dipslayName_arr = {'Ctrl', 'Mrstm1', 'Mrstm2', 'Mrstm3', 'Mrstm4'}; 
       
    for i_set=1:num_sets
        start_i = (i_set-1)*num_levels+1;
        end_i = (i_set-1)*num_levels+num_levels;
        disp_performance = [(1-performance(1,start_i:end_i)) flip(performance(2,start_i:end_i))];
        if i_set==1
            plot(disp_performance, color{i_set}, 'DisplayName', dipslayName_arr{i_set})
        else
            hold on, plot(disp_performance, color{i_set}, 'DisplayName', dipslayName_arr{i_set}), hold off;
        end
        xlabel('cir-rad');
        ylabel('radial response');
        title('Performance Plot');

    end


   


end