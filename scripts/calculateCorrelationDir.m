function [correlations, avgCorr] = calculateCorrelationDir(denoisedAudioArray, cleanOriginalDir, numDenoised, numClean)
% calculateCorrelationDir  Computes correlation metrics between clean and denoised audio files.
%
%   [correlations, avgCorr] = calculateCorrelationDir(denoisedAudioArray, cleanOriginalDir, numDenoised, numClean)
%
%   Compares each clean audio file in a directory against multiple versions of
%   its denoised counterparts and calculates the correlation values.
%
%   Inputs:
%       denoisedAudioArray - Cell array containing denoised audio signals
%       cleanOriginalDir   - Directory containing clean .wav files
%       numDenoised        - Number of denoised versions per clean file (default: 1)
%       numClean           - Number of clean files to compare (default: 1)
%
%   Outputs:
%       correlations        - Matrix of correlation values (size: numClean × numDenoised)
%       avgCorr             - Scalar average of all correlation values
%
%   Notes:
%       - Assumes filenames of clean files begin with a numeric index (e.g., "10.wav")
%       - Calls calculateAudioError to compute the correlation metric
%       - Assumes audio is sampled at or will be resampled to 8 kHz

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
            denoisedAudio = denoisedAudioArray{(i - 1) * numDenoised + j};

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
