folder_path = '\\SpikeVault\Younes\NED\Training\3_AdaptiveBiasCorrection';

% Get all .bhv2 files
files = dir(fullfile(folder_path, '*.bhv2'));

performance = nan(1, length(files));
file_labels = strings(1, length(files));

for i = 1:length(files)
    i

    % Full file address
    filename = fullfile(folder_path, files(i).name);

    % Load bhv2 file
    beh = mlread(filename);

    % Extract TrialError
    trial_errors = [beh.TrialError];

    % Keep only correct and wrong-choice trials
    valid_errors = trial_errors(trial_errors == 0 | trial_errors == 5);

    % Calculate performance
    performance(i) = sum(valid_errors == 0) / length(valid_errors);

    % Keep first 6 characters of file name for x-axis
    file_labels(i) = extractBefore(files(i).name, 7);

end

% Plot
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