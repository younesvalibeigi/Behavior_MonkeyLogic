function cond_no = cond_selection(TrialRecord)
    errors = TrialRecord.TrialErrors;
    conditions = TrialRecord.ConditionsPlayed;
    % Example arrays (replace these with your actual data)
    %errors = [0, 1, 2, 5, 0, 0, 5, 5];
    %conditio [1, 2, 1, 3, 2, 1, 2, 3];
    
    % Find unique elements in conditions
    unique_conditions = unique(conditions);
    
    % Initialize arrays to store ratios
    ratios = zeros(size(unique_conditions));
    
    % Calculate ratios for each unique condition
    for i = 1:numel(unique_conditions)
        % Find indices where conditions match the current unique condition
        indices = find(conditions == unique_conditions(i));
        
        % Get error values corresponding to these indices
        corresponding_errors = errors(indices);
        
        % Calculate ratio for non-zero and non-5 error values
        if ~isempty(corresponding_errors)
            nonzero_errors = corresponding_errors(corresponding_errors ~= 0 & corresponding_errors ~= 5);
            num_nonzero_errors = numel(nonzero_errors);
            num_total_errors = numel(corresponding_errors);
            zero_errors = corresponding_errors(corresponding_errors == 0);
            five_errors = corresponding_errors(corresponding_errors == 5);
            num_zero_errors = numel(zero_errors);
            num_five_errors = numel(five_errors);
            ratios(i) = num_zero_errors / (num_zero_errors+num_five_errors);
        else
            ratios(i) = NaN; % No errors for this condition
        end
    end
    
    % Display ratios
    %disp('Ratios for each unique condition:');
    %disp([unique_conditions', ratios']);
 



end