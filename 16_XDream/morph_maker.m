% Folders to process
folders = {
    'C:\Users\labuser\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\16_XDream\250923_123624__evol_stimuli_b', ...
    'C:\Users\labuser\AppData\Roaming\MathWorks\MATLAB Add-Ons\Apps\NIMHMonkeyLogic22\task\Behavior_MonkeyLogic\16_XDream\250923_130348__evol_stimuli_c'
};
numSteps = 9;
%process_last_block_avg()
process_last_block_avg_morph(folders, numSteps)
process_last_block_avg_slerp(folders, numSteps)

function process_last_block_avg(folders)
    

    for f = 1:length(folders)
        folder = folders{f};
        % Find all PNGs in the folder
        files = dir(fullfile(folder, 'blk*_img_*.png'));

        % Extract block and image numbers
        blkNums = arrayfun(@(x) sscanf(x.name, 'blk%d_img_%d.png'), files, 'UniformOutput', false);
        blkNums = cell2mat(blkNums');  % Nx2 array: [block, image]
        blocks = blkNums(1,:);

        % Get last block number
        lastBlock = max(blocks);

        % Keep only images 1–40 from last block
        idx = (blocks(1,:) == lastBlock) & (blkNums(2,:) >= 1 & blkNums(2,:) <= 40);
        lastBlockFiles = files(idx);

        % Sort by image number
        [~, order] = sort(blkNums(2,idx));
        lastBlockFiles = lastBlockFiles(order);

        % Initialize average accumulator
        img = imread(fullfile(folder, lastBlockFiles(1).name));
        avg_img = zeros(size(img));

        % Loop through 40 images and accumulate
        for i = 1:length(lastBlockFiles)
            img = imread(fullfile(folder, lastBlockFiles(i).name));
            if size(img,3) == 3
                %img = rgb2gray(img); % convert to grayscale if RGB
            end
            %small = imresize(img, [64 64], 'bicubic');
            avg_img = avg_img + double(img);
        end

        % Divide by number of images to get mean
        avg_img = avg_img / length(lastBlockFiles);
        avg_img = uint8(avg_img);

        % Save averaged image
        outName = fullfile([pwd '\averaged_images'], sprintf('avg_lastblock_f%d.png', f));
        imwrite(avg_img, outName);

        fprintf('Processed folder %d: saved %s\n', f, outName);
    end
end
function process_last_block_avg_morph(folders, numSteps)
    
    avg_imgs = cell(1,2); % store two averaged images

    for f = 1:length(folders)
        folder = folders{f};
        files = dir(fullfile(folder, 'blk*_img_*.png'));

        blkNums = arrayfun(@(x) sscanf(x.name, 'blk%d_img_%d.png'), files, 'UniformOutput', false);
        blkNums = cell2mat(blkNums');  
        blocks = blkNums(1,:);

        lastBlock = max(blocks);

        idx = (blocks(1,:) == lastBlock) & (blkNums(2,:) >= 1 & blkNums(2,:) <= 40);
        lastBlockFiles = files(idx);

        [~, order] = sort(blkNums(2,idx));
        lastBlockFiles = lastBlockFiles(order);

        % Initialize with first image size
        img = imread(fullfile(folder, lastBlockFiles(1).name));
        avg_img = zeros(size(img));

        % Average across 40 images
        for i = 1:length(lastBlockFiles)
            img = imread(fullfile(folder, lastBlockFiles(i).name));
            avg_img = avg_img + double(img);
        end

        avg_img = avg_img / length(lastBlockFiles);
        avg_img = uint8(avg_img);

        avg_imgs{f} = avg_img; % store
    end

    % ---- Now create morph sequence ----
    img1 = double(avg_imgs{1});
    img2 = double(avg_imgs{2});

    outDir = fullfile(pwd, 'morph_images_linear');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %numSteps = 13; % total images (including endpoints)

    for k = 1:numSteps
        alpha = (k-1)/(numSteps-1); % goes from 0 to 1
        morph_img = (1-alpha)*img1 + alpha*img2;
        morph_img = uint8(morph_img);

        outName = fullfile(outDir, sprintf('morph_linear%d.png', k));
        imwrite(morph_img, outName);
        fprintf('Saved %s\n', outName);
    end
end

function process_last_block_avg_slerp(folders, numSteps)
    

    avg_imgs = cell(1,2); % store two averaged images

    for f = 1:length(folders)
        folder = folders{f};
        files = dir(fullfile(folder, 'blk*_img_*.png'));

        blkNums = arrayfun(@(x) sscanf(x.name, 'blk%d_img_%d.png'), files, 'UniformOutput', false);
        blkNums = cell2mat(blkNums');  
        blocks = blkNums(1,:);

        lastBlock = max(blocks);

        idx = (blocks(1,:) == lastBlock) & (blkNums(2,:) >= 1 & blkNums(2,:) <= 40);
        lastBlockFiles = files(idx);

        [~, order] = sort(blkNums(2,idx));
        lastBlockFiles = lastBlockFiles(order);

        % Initialize with first image size
        img = imread(fullfile(folder, lastBlockFiles(1).name));
        avg_img = zeros(size(img));

        % Average across 40 images
        for i = 1:length(lastBlockFiles)
            img = imread(fullfile(folder, lastBlockFiles(i).name));
            avg_img = avg_img + double(img);
        end

        avg_img = avg_img / length(lastBlockFiles);
        avg_img = uint8(avg_img);

        avg_imgs{f} = avg_img; % store
    end

    % ---- Spherical interpolation (slerp) ----
    img1 = double(avg_imgs{1});
    img2 = double(avg_imgs{2});

    v1 = img1(:);
    v2 = img2(:);

    % normalize vectors
    v1n = v1 / norm(v1);
    v2n = v2 / norm(v2);

    % angle between them
    cosTheta = dot(v1n, v2n);
    cosTheta = max(min(cosTheta,1),-1); % clamp numerical errors
    theta = acos(cosTheta);

    outDir = fullfile(pwd, 'morph_images_slerp');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %numSteps = 13; % total images

    for k = 1:numSteps
        alpha = (k-1)/(numSteps-1);

        if abs(theta) < 1e-6
            % if vectors are almost the same, fallback to linear interp
            v = (1-alpha)*v1 + alpha*v2;
            disp('ss')
        else
            % spherical interpolation
            v = (sin((1-alpha)*theta)/sin(theta))*v1 + (sin(alpha*theta)/sin(theta))*v2;
        end

        morph_img = reshape(v, size(img1));
        morph_img = uint8(morph_img);

        outName = fullfile(outDir, sprintf('morph_slerp%d.png', k));
        imwrite(morph_img, outName);
        fprintf('Saved %s\n', outName);
    end
end
