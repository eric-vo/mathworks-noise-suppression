function [noiseReductionRatios, avgNoiseReductionRatio] = calculateNoiseReductionRatio(denoisedAudioArray, cleanOriginalDir, noisyOriginalDir, numDenoised)
% calculateNoiseReductionRatio  Computes noise reduction ratios of denoised over noisy audio.
%
%   [noiseReductionRatios, avgNoiseReductionRatio] = calculateNoiseReductionRatio(...)
%
%   For each clean file and corresponding denoised version, computes:
%       noiseReductionRatio = (noisyMSE - denoisedMSE) / noisyMSE
%
%   Inputs:
%       denoisedAudioArray - Cell array of denoised audio signals
%       cleanOriginalDir   - Directory with clean .wav files (e.g., "10.wav")
%       noisyOriginalDir   - Directory with noisy .wav files (e.g., "10_<x>.wav")
%       numDenoised        - Number of denoised/noisy versions per clean file
%       numClean           - Number of clean files to compare
%
%   Outputs:
%       noiseReductionRatios    - Matrix (numClean x numDenoised) of noise reduction ratios
%       avgImprovement     - Average noise reduction ratio

    arguments
        denoisedAudioArray
        cleanOriginalDir
        noisyOriginalDir
        numDenoised = 1
    end

    targetFs = 8000;

    % === Sort clean files ===
    cleanFiles = dir(fullfile(cleanOriginalDir, '*.wav'));
    numClean = length(cleanFiles);
    cleanNames = {cleanFiles.name};
    [~, sortIdx] = sort(cleanNames);
    sortedCleanFiles = cleanFiles(sortIdx);
    sortedCleanNums = (1:length(sortedCleanFiles));  % Just use 1-based indexing if names aren't numeric

    % === Sort noisy files ===
    noisyFiles = dir(fullfile(noisyOriginalDir, '*.wav'));
    noisyNames = {noisyFiles.name};
    [~, noisySortIdx] = sort(noisyNames);
    sortedNoisyFiles = noisyFiles(noisySortIdx);

    % === Output matrix ===
    noiseReductionRatios = zeros(numClean, numDenoised);

    for i = 1:numClean
        cleanPath = fullfile(cleanOriginalDir, sortedCleanFiles(i).name);
        [cleanAudio, cleanFs] = audioread(cleanPath);
        if cleanFs ~= targetFs
            cleanAudio = resample(cleanAudio, targetFs, cleanFs);
        end

        for j = 1:numDenoised
            idx = (i - 1) * numDenoised + j;
        
            % === Load denoised audio ===
            denoisedAudio = denoisedAudioArray{idx};
            if size(denoisedAudio, 2) > 1
                denoisedAudio = mean(denoisedAudio, 2);
            end
        
            % === Load corresponding noisy audio ===
            if idx > length(sortedNoisyFiles)
                warning('Missing noisy file for clean %s, version %d. Skipping.', sortedCleanFiles(i).name, j);
                noiseReductionRatios(i, j) = NaN;
                continue;
            end
        
            noisyFileName = sortedNoisyFiles(idx).name;
            noisyPath = fullfile(noisyOriginalDir, noisyFileName);
            [noisyAudio, noisyFs] = audioread(noisyPath);
            if noisyFs ~= targetFs
                noisyAudio = resample(noisyAudio, targetFs, noisyFs);
            end
            if size(noisyAudio, 2) > 1
                noisyAudio = mean(noisyAudio, 2);
            end
        
            % === Debugging Info ===
            fprintf('\n--- Debug Info (i=%d, j=%d, idx=%d) ---\n', i, j, idx);
            fprintf('Clean file      : %s\n', sortedCleanFiles(i).name);
            fprintf('Noisy file      : %s\n', noisyFileName);
            fprintf('Denoised index  : %d (from denoisedAudioArray)\n', idx);
            fprintf('Clean length    : %d samples\n', length(cleanAudio));
            fprintf('Noisy length    : %d samples\n', length(noisyAudio));
            fprintf('Denoised length : %d samples\n', length(denoisedAudio));
            fprintf('-----------------------------\n');
        
            % === Compute Ratios ===
            denoisedMetrics = calculateAudioError(cleanAudio, denoisedAudio);
            noisyMetrics = calculateAudioError(cleanAudio, noisyAudio);   
            noiseReductionRatio = (noisyMetrics.MSE - denoisedMetrics.MSE) / noisyMetrics.MSE;
            noiseReductionRatios(i, j) = noiseReductionRatio;
        end

    end

    % === Report noise reduction ratios ===
    fprintf('\n');
    for i = 1:numClean
        fprintf('Noise reduction ratio improvements for clean file %d: ', sortedCleanNums(i));
        fprintf('%.2f ', noiseReductionRatios(i, :));
        fprintf('\n');
    end

    avgNoiseReductionRatio = mean(noiseReductionRatios(~isnan(noiseReductionRatios)), 'all');
    fprintf('Average noise reduction ratio across all files: %.2f\n', avgNoiseReductionRatio);
end
