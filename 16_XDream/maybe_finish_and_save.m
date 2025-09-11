function [done, C] = maybe_finish_and_save(MAX_BLOCKS, current_block_idx, OUT_DIR_REL, codes_all, scores_all, generations, img_traj)
% Return true and a dummy C if we reached the final block; also save artifacts.
done = false; C = [];
if current_block_idx >= MAX_BLOCKS
    TrialRecord.NextBlock = -1;  %#ok<NASGU> (ML reads it but not required to return)
    TrialRecord.NextCondition = 1; %#ok<NASGU>
    C = {'fix(0,0)'};  % dummy

    try, save(fullfile(OUT_DIR_REL,'codes_all.mat'),      'codes_all',      '-v7.3'); end
    try, save(fullfile(OUT_DIR_REL,'scores_all.mat'),     'scores_all',     '-v7.3'); end
    try, save(fullfile(OUT_DIR_REL,'generations.mat'),    'generations',    '-v7.3'); end
    try, save(fullfile(OUT_DIR_REL,'img_traj.mat'),       'img_traj',       '-v7.3'); end

    % Optional quick-look plots (comment out if unwanted during task)
    try
        figure; montage(img_traj); xlabel("Generation"); ylabel("activation");
        figure; scatter(generations, scores_all); xlabel("Generation"); ylabel("activation");
    catch
    end

    done = true;
end
end