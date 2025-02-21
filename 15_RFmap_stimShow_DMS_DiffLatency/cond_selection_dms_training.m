function cond_no = cond_selection_dms_training(TrialRecord, MLConfig)
    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;
    % This is the setting for noise level, Arya, before sept2024-Feb2025
    % before feb 12, 2025
    %N=4*6;
    
    % This is the seeting for contrast level arya after feb 12,2025
    num_levels = 7;
    %num_sets = 2;
    N=4*num_levels;


    cond_set = 1:N;
    performance = 0;
    anal_range = N;%*2;
    freqs = ones(1,N)*2;
    indices_played = find(errors == 0 | errors == 5);
    num_toAnal = floor(length(indices_played)/anal_range)*anal_range; % How many should be analyzed
    
    if mod(length(indices_played), anal_range)==0
        disp([num2str(floor(length(indices_played)/anal_range)) '  point of analysis'])

    end

    if num_toAnal<anal_range
        cond_played = conditions(indices_played);
        error_played = errors(indices_played);

    elseif num_toAnal>=anal_range
        cond_played = conditions(indices_played(1:num_toAnal));
        error_played = errors(indices_played(1:num_toAnal));
        sum_error_correct = zeros(2,N/4); % first row is cir second is rad over six levels
        sum_error_wrong= zeros(2,N/4);
        for i=1:(N/2)/2 % we go for six levels
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
        performance_ratio = performance(1,:) ./ performance(2,:); %cir/rad
        
        
        for i=1:N/4
            if performance_ratio(i)>1.5 % bias toward cir
                if performance_ratio(i)>2 % more bias toward cir
                    theRatio = performance_ratio(i)*2;
                    %cir
                    freqs(1,(i-1)*4+1) = freqs(1,(i-1)*4+1)/theRatio;
                    freqs(1,(i-1)*4+2) = freqs(1,(i-1)*4+2)/theRatio;
                    %rad
                    freqs(1,(i-1)*4+3) = freqs(1,(i-1)*4+3)*theRatio;
                    freqs(1,(i-1)*4+4) = freqs(1,(i-1)*4+4)*theRatio;
                else
                    %cir
                    freqs(1,(i-1)*4+1) = freqs(1,(i-1)*4+1)/2;
                    freqs(1,(i-1)*4+2) = freqs(1,(i-1)*4+2)/2;
                    %rad
                    freqs(1,(i-1)*4+3) = freqs(1,(i-1)*4+3)*2;
                    freqs(1,(i-1)*4+4) = freqs(1,(i-1)*4+4)*2;
                end


            elseif performance_ratio(i)<0.75 % bias toward rad
                if performance_ratio(i)<0.50 % more bias toward rad
                    theRatio = (1/performance_ratio(i))*2;
                    %cir
                    freqs(1,(i-1)*4+1) = freqs(1,(i-1)*4+1)*theRatio;
                    freqs(1,(i-1)*4+2) = freqs(1,(i-1)*4+2)*theRatio;
                    %rad
                    freqs(1,(i-1)*4+3) = freqs(1,(i-1)*4+3)/theRatio;
                    freqs(1,(i-1)*4+4) = freqs(1,(i-1)*4+4)/theRatio;
                else
                    %cir
                    freqs(1,(i-1)*4+1) = freqs(1,(i-1)*4+1)*2;
                    freqs(1,(i-1)*4+2) = freqs(1,(i-1)*4+2)*2;
                    %rad
                    freqs(1,(i-1)*4+3) = freqs(1,(i-1)*4+3)/2;
                    freqs(1,(i-1)*4+4) = freqs(1,(i-1)*4+4)/2;
                end
            end
        end
    end
    %freqs
    %performance
    freqs(isnan(freqs)) = 2;
    freqs(isinf(freqs)) = 10;
    weights = freqs / sum(freqs);
    if mod(length(indices_played), anal_range)==0
        disp(freqs)
        %disp(weights)
    end
    
    cond_no = randsample(cond_set, 1, true, weights);


    
    % remainder_length = mod(length(cond_played), N);
    % % print this:
    % if remainder_length == 0
    %     num_fullSet = floor(length(cond_played) / N);
    %     disp([num2str(num_fullSet) ' full set is complete'])
    % end
    % remainder_elements = cond_played(end-remainder_length+1:end);
    % 
    % %remainder_elements = cond_played(mod(1:length(cond_played), N) > 0)
    % if length(remainder_elements)>0
    %     available_cond_set = setdiff(cond_set, remainder_elements);
    % else
    %     available_cond_set = cond_set;
    % end
    % if length(available_cond_set)>1
    %     cond_no = randsample(available_cond_set, 1);
    % else
    %     cond_no = available_cond_set(1);
    % end

    % if monkey skip a trial, repeat it
    if length(errors)>1
        if ~(errors(end) == 0 || errors(end) == 5)
            cond_no = conditions(end);
        end
    end


    % if make a mistake 3 times for an stimulus, keep showing it until she
    % gets it right
    if exist('cond_played', 'var') && length(cond_played)>2
        %if length(cond_played)>1
            indices_lastStim = find(cond_played == cond_played(end-1)); % Previous trial not this trial
            errors_lastStim = error_played(indices_lastStim);
            if length(errors_lastStim)>3
                if errors_lastStim(end) == 5 && errors_lastStim(end-1) == 5 && errors_lastStim(end-2) == 5
                    disp("Making a mistke 3 times")
                    cond_no = cond_played(end-1);
                end
            end
        %end
    end
    %cond_no = 24;


end