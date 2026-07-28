%%
loaded_data = load('Performances.mat');
files = loaded_data.files;
%%
folder_path = '\\SpikeVault\Younes\NED\Training\3_AdaptiveBiasCorrection';
%folder_path = '\\SpikeVault\Younes\Arya\4_Recording_contrastLevel_microstimulation\DMS_Training_2024';
% Get all .bhv2 files
all_files  = dir(fullfile(folder_path, '*.bhv2'));

% Find sessions that are not already stored in files
existing_names = {files.name};
is_new = ~ismember({all_files.name}, existing_names);

new_files = all_files(is_new);

%performance = nan(1, length(files));
%file_labels = strings(1, length(files));
new_performance = nan(1, length(new_files));

for i = 1:length(new_files)
    i

    % Full file address
    filename = fullfile(folder_path, new_files(i).name);

    % Load bhv2 file
    beh = mlread(filename);

    % Extract condition number and trial errors
    conditions = [beh.Condition];      % If this gives an error, use [beh.ConditionNumber]
    trial_errors = [beh.TrialError];

    % Keep only the first 4 conditions
    idx = conditions <= 4;
    
    % Select those trials
    trial_errors = trial_errors(idx);


    % Keep only correct and wrong-choice trials
    valid_errors = trial_errors(trial_errors == 0 | trial_errors == 5);

    % Calculate performance
    %performance(i) = sum(valid_errors == 0) / length(valid_errors);
    if isempty(valid_errors)
        new_performance(i) = NaN;
    else
        new_performance(i) = sum(valid_errors == 0) / length(valid_errors);
    end

    % Keep first 6 characters of file name for x-axis
    %file_labels(i) = extractBefore(files(i).name, 7);

end

% Add performance as a field to the new files
performance_cells = num2cell(new_performance);
[new_files.performance] = performance_cells{:};

% Add the newly analyzed sessions to the original files
files = [files; new_files];

%% Plot
performance = [files.performance];
file_labels = strings(1, length(files));

for i = 1:length(files)
    file_labels(i) = extractBefore(files(i).name, 7);
end

figure;
bar(performance * 100);
xticks(1:length(files));
xticklabels(file_labels);
xtickangle(45);

ylabel('Performance (%)');
xlabel('Session');
title('Behavioral Performance Across Sessions');

ylim([0 100]);
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

%% Save
save('Performances.mat', 'files');