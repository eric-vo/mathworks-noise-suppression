function [correlations, avgCorr] = calculateCorrelationDir(denoisedAudioArray, cleanOriginalDir, numDenoised, numClean)
    arguments
        denoisedAudioArray
        cleanOriginalDir
        numDenoised = 1
        numClean = 1
    end
    
    targetFs = 8000;

    % Get all .wav files from the cleanOriginalDir
    fileList = dir(fullfile(cleanOriginalDir, '*.wav'));

    % Extract numeric part of each filename (e.g., "10.wav" → 10)
    fileNums = arrayfun(@(f) sscanf(f.name, '%d'), fileList);

    % Sort files by numeric part in ascending order
    [~, sortIdx] = sort(fileNums, 'ascend');
    sortedFiles = fileList(sortIdx);
    sortedNums = fileNums(sortIdx);

    % Prepare output matrix
    correlations = zeros(numClean, numDenoised);

    % Loop over sorted clean files
    for i = 1:numClean
        cleanFile = fullfile(cleanOriginalDir, sortedFiles(i).name);
        [cleanAudio, cleanFs] = audioread(cleanFile);

        % Resample to targetFs if needed
        if cleanFs ~= targetFs
            cleanAudio = resample(cleanAudio, targetFs, cleanFs);
        end

        for j = 1:numDenoised
            fprintf('Processing clean file %s, denoised version %d\n', sortedFiles(i).name, j);

            % Get denoised audio from array
            denoisedAudio = denoisedAudioArray{(i - 1) * 10 + j};

            % If stereo, convert to mono
            if size(denoisedAudio, 2) > 1
                denoisedAudio = mean(denoisedAudio, 2);
            end

            % % Optional audio playback
            % soundsc(cleanAudio)
            % pause()
            % soundsc(denoisedAudio)

            % Compute error metrics
            errorMetrics = calculateAudioError(cleanAudio, denoisedAudio);
            correlations(i, j) = errorMetrics.Correlation;

            fprintf('\n')
        end
    end

    % Print correlation values
    for i = 1:numClean
        cleanIndex = sortedNums(i);
        fprintf('Correlation values for clean file %d: ', cleanIndex);
        fprintf('%.4f ', correlations(cleanIndex, :));
        fprintf('\n');
    end

    % Compute and print average correlation
    avgCorr = mean(correlations(:));
    fprintf('Average correlation across all files: %.4f\n', avgCorr);
end
