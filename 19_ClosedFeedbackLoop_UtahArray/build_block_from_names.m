function [all_names, cond_table] = build_block_from_names(name_list, outdir_abs, outdir_rel, N_COND, IMGS_PER_COND, block_idx)
% name_list: cellstr of source file names, length IMGS_PER_BLOCK.
% Copies files into outdir_abs with standardized names:
%    blk%03d_img_%03d.png  (e.g., blk001_img_001.png)
% Returns:
%   all_names: IMGS_PER_BLOCKx1 cellstr of relative paths like '<outdir_rel>/blk001_img_001.png'
%   cond_table: N_COND x IMGS_PER_COND cellstr (each row is a condition's IMGS_PER_COND images)

IMGS_PER_BLOCK = numel(name_list);
all_names = cell(IMGS_PER_BLOCK,1);

for i = 1:IMGS_PER_BLOCK
    src = name_list{i};
    if ~ischar(src), src = char(src); end
    % Normalize separators and resolve absolute path if needed
    src_norm = strrep(src, '\', filesep);
    if ~exist(src_norm,'file')
        src_norm = fullfile(pwd, src_norm);  % try relative to task folder
    end
    if ~exist(src_norm,'file')
        error('Source image not found: %s', name_list{i});
    end

    fname = sprintf('blk%03d_img_%03d.png', block_idx, i);
    fpath = fullfile(outdir_abs, fname);
    copyfile(src_norm, fpath, 'f');  % overwrite if exists

    % Relative path for MonkeyLogic
    all_names{i} = fullfile(outdir_rel, fname);
end

% Make N_COND×IMGS_PER_COND table of filenames
cond_table = reshape(all_names, IMGS_PER_COND, N_COND).';

end
