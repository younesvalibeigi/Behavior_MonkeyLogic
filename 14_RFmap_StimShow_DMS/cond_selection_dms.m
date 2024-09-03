function cond_no = cond_selection_dms(TrialRecord, MLConfig)
    conditions = TrialRecord.ConditionsPlayed;
    errors = TrialRecord.TrialErrors;
    
    N=24;
    cond_set = 1:N;


    indices_played = find(errors == 0 | errors == 5);
    cond_played = conditions(indices_played);
    remainder_length = mod(length(cond_played), N);
    % print this:
    if remainder_length == 0
        num_fullSet = floor(length(cond_played) / N);
        disp([num2str(num_fullSet) ' full set is complete'])
    end
    remainder_elements = cond_played(end-remainder_length+1:end);

    %remainder_elements = cond_played(mod(1:length(cond_played), N) > 0)
    if length(remainder_elements)>0
        available_cond_set = setdiff(cond_set, remainder_elements);
    else
        available_cond_set = cond_set;
    end
    if length(available_cond_set)>1
        cond_no = randsample(available_cond_set, 1);
    else
        cond_no = available_cond_set(1);
    end

    if length(errors)>1
        if ~(errors(end) == 0 || errors(end) == 5)
            cond_no = conditions(end);
        end
    end


end