%% evaluate_correlation.m
% Evaluate correlation between clean and denoised speech audio files.
%
% This script:
%   - Loops over a set of clean audio files and corresponding denoised versions
%   - Resamples all files to 8 kHz (if needed)
%   - Computes correlation between each clean-denoised pair using calculateAudioError
%   - Prints individual and average correlation scores
%
% Requirements:
%   - cleanDir: folder with clean reference .wav files named as <index>.wav (e.g., 1.wav, 2.wav, ...)
%   - denoisedDir: folder with denoised .wav files named as <index>_<noiseType>_<snr>.wav
%   - calculateAudioError must be available on the MATLAB path
%
% Example:
%   Run this script after denoising to check how well the denoised output correlates
%   with the original clean speech signals.

% Set root paths and parameters
cleanDir = 'data/test/gabrielSamples/clean';
denoisedDir = 'data/test/gabrielSamples/output_wav';
numClean = 10;
numDenoised = 10;

targetFs = 8000;

% Prepare output matrix
correlationVals = zeros(numClean, numDenoised);

% Loop over clean files
for i = 1:numClean
    cleanFile = fullfile(cleanDir, sprintf('%d.wav', i));
    [cleanAudio, cleanFs] = audioread(cleanFile);

    % Resample if needed - Use 8 kHz
    if cleanFs ~= targetFs
        cleanAudio = resample(cleanAudio, targetFs, cleanFs);
    end
    
    for j = 1:numDenoised
        % Find the relevant noisy file. Use wildcard for <xx>.
        pattern = sprintf('%d_*.wav', i);
        files = dir(fullfile(denoisedDir, pattern));
        % Defensive: Ensure at least five noisy files exist per clean
        if numel(files) < numDenoised
            error('Not enough noisy files for clean file %d', i);
        end
        denoisedFile = fullfile(denoisedDir, files(j).name);

        % Print progress
        fprintf('Processing clean file %d, denoised version %d: %s\n', i, j, files(j).name);

        % Read and denoise
        [denoisedAudio, denoisedFs] = audioread(denoisedFile);
        if size(denoisedAudio, 2) > 1
            denoisedAudio = mean(denoisedAudio, 2);
        end

        % Resample if needed - Use 8 kHz
        if denoisedFs ~= targetFs
            denoisedAudio = resample(denoisedAudio, targetFs, denoisedFs);
        end

        % Compute error metrics
        errorMetrics = calculateAudioError(cleanAudio, denoisedAudio);
        correlationVals(i,j) = errorMetrics.Correlation;

        fprintf('\n')
    end
end

for i = 1:numClean
    % Print correlation values for this clean file
    fprintf('Correlation values for clean file %d: ', i);
    fprintf('%.4f ', correlationVals(i,:));
    fprintf('\n');
end

% Print overall average correlation
avgCorr = mean(correlationVals(:));
fprintf('Average correlation across all files: %.4f\n', avgCorr);
