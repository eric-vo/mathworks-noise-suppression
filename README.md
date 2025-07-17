%% mathworks-noise-suppression

%% calculateAudioError Script

function errorMetrics = calculateAudioError(cleanAudio, denoisedAudio)
% CALCULATEAUDIOERROR Calculate various error metrics between clean and denoised audio
% Input:
%   cleanAudio - Original clean audio signal
%   denoisedAudio - Denoised audio signal

% Output:

%   errorMetrics - Structure containing various error metrics

% Ensure both signals have the same length
minLength = min(length(cleanAudio), length(denoisedAudio));
cleanAudio = cleanAudio(1:minLength);
denoisedAudio = denoisedAudio(1:minLength);

% Calculate squared differences
squaredDifferences = (cleanAudio - denoisedAudio).^2;

% RMSE (Root Mean Square Error)
rmse_error = sqrt(mean(squaredDifferences));

% SNR in dB
signal_power = mean(cleanAudio.^2);
noise_power = mean(squaredDifferences);
snr_db = 10 * log10(signal_power / noise_power);
clean_rms = sqrt(mean(cleanAudio.^2));
nrmse_error = rmse_error / clean_rms;

% PSNR (Peak Signal-to-Noise Ratio)
max_signal = max(abs(cleanAudio));
psnr_db = 20 * log10(max_signal / rmse_error);

% Correlation coefficient
correlation_value = correlation(1,2);

% Store results
errorMetrics = struct();
errorMetrics.RMSE = rmse_error;
errorMetrics.MSE = mse_error;
errorMetrics.SNR_dB = snr_db;
errorMetrics.NRMSE = nrmse_error;
errorMetrics.PSNR_dB = psnr_db;
errorMetrics.MAE = mae_error;
errorMetrics.Correlation = correlation_value;

% Display results
fprintf('=== Audio Error Metrics ===\n');
fprintf('RMSE: %.6f\n', rmse_error);
fprintf('MSE: %.6f\n', mse_error);
fprintf('SNR: %.2f dB\n', snr_db);
fprintf('PSNR: %.2f dB\n', psnr_db);
fprintf('MAE: %.6f\n', mae_error);
fprintf('Correlation: %.6f\n', correlation_value);
end

%% calculateCorrelationBatch script

% Construct the path to the current clean audio file.
cleanFile = fullfile(cleanDir, sprintf('%d.wav', i));

% Read the clean audio file and its sampling rate.
[cleanAudio, cleanFs] = audioread(cleanFile);

% Resample the clean audio to 8 kHz if it is not already.
if cleanFs ~= targetFs
    cleanAudio = resample(cleanAudio, targetFs, cleanFs);
end

% Loop through each denoised version of the current clean audio.
for j = 1:numDenoised

    % Construct a filename pattern to find denoised files for the current clean file.
    pattern = sprintf('%d_*.wav', i);

    % List all matching denoised files in the directory.
    files = dir(fullfile(denoisedDir, pattern));

    % Ensure there are enough denoised files for comparison.
    if numel(files) < numDenoised
        error('Not enough noisy files for clean file %d', i);
    end

    % Get the full path to the current denoised audio file.
    denoisedFile = fullfile(denoisedDir, files(j).name);

    % Print progress to the console.
    fprintf('Processing clean file %d, denoised version %d: %s\n', i, j, files(j).name);

    % Read the denoised audio file and its sampling rate.
    [denoisedAudio, denoisedFs] = audioread(denoisedFile);

    % If stereo, convert the denoised audio to mono.
    if size(denoisedAudio, 2) > 1
        denoisedAudio = mean(denoisedAudio, 2);
    end

    % Resample denoised audio to 8 kHz if necessary.
    if denoisedFs ~= targetFs
        denoisedAudio = resample(denoisedAudio, targetFs, denoisedFs);
    end

    % Compute error metrics between clean and denoised audio.
    errorMetrics = calculateAudioError(cleanAudio, denoisedAudio);

    % Store the correlation value in the results matrix.
    correlationVals(i,j) = errorMetrics.Correlation;

    denoiseSpeechTest
    % Define input and output directories
inputDir = "data/test/gabrielSamples/noisy";
outputDir = "data/test/gabrielSamples/output_wav";

%% Load fine-tuned model
s = load("models/denoiseNet_FineTuned_VBD.mat");
denoiseNet = s.netFineTuned;         % Trained deep neural network
noisyMean = s.noisyMean;             % Mean of noisy data (for normalization)
noisyStd = s.noisyStd;               % Std of noisy data
cleanMean = s.cleanMean;             % Mean of clean data (for re-scaling)
cleanStd = s.cleanStd;               % Std of clean data

% Setup STFT parameters
win = hamming(256, "periodic");      % Window function
overlap = round(0.75 * 256);         % 75% overlap
fftLength = 256;                     % FFT length
numFeatures = fftLength / 2 + 1;     % Number of frequency bins
numSegments = 8;                     % Context window size
targetFs = 8000;                     % Target sample rate

%% Process all .wav files in inputDir
fileList = dir(fullfile(inputDir, '*.wav'));

for k = 1:length(fileList)
    inputPath = fullfile(inputDir, fileList(k).name);        % Path to noisy file
    [noisyAudio, fs] = audioread(inputPath);                 % Load audio

    % Convert to mono if stereo
    if size(noisyAudio, 2) > 1
        noisyAudio = mean(noisyAudio, 2);
        disp('Changed to mono')
    end

    % Resample to targetFs if needed
    if fs ~= targetFs
        disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)])
        noisyAudio = resample(noisyAudio, targetFs, fs);
        fs = targetFs;
    end

    % Compute STFT
    noisySTFT = stft(noisyAudio, Window=win, OverlapLength=overlap, fftLength=fftLength);
    noisyPhase = angle(noisySTFT(numFeatures-1:end, :));     % Extract phase
    noisySTFT = abs(noisySTFT(numFeatures-1:end, :));        % Get magnitude

    % Build 8-frame input context
    noisySTFT = [noisySTFT(:, 1:numSegments-1), noisySTFT];
    numFrames = size(noisySTFT, 2) - numSegments + 1;
    predictors = zeros(129, numSegments, 1, numFrames);
    for idx = 1:numFrames
        predictors(:, :, 1, idx) = noisySTFT(:, idx:idx + numSegments - 1);
    end

    % Normalize predictors using noisy stats
    predictors(:) = (predictors(:) - noisyMean) / noisyStd;

    % Predict denoised STFT magnitudes using neural network
    STFTDenoised = predict(denoiseNet, predictors);
    STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;     % Re-scale to original units
    STFTDenoised = STFTDenoised.';                                % Transpose for reconstruction
    STFTDenoised = STFTDenoised .* exp(1j * noisyPhase);          % Reapply phase
    STFTDenoised = [conj(STFTDenoised(end-1:-1:2, :)); STFTDenoised]; % Mirror spectrum for iSTFT

    % Inverse STFT to reconstruct time-domain signal
    denoisedAudio = istft(STFTDenoised, Window=win, OverlapLength=overlap, fftLength=fftLength, ConjugateSymmetric=true);

    % Save denoised audio
    [~, name, ~] = fileparts(fileList(k).name);
    outputName = strcat(name, '_dn.wav');
    outputPath = fullfile(outputDir, outputName);
    audiowrite(outputPath, denoisedAudio, fs);

    % Print progress
    fprintf("Processed: %s → %s\n", fileList(k).name, outputName);
end

% Final message after processing all files
disp("All files denoised and saved.");


    % Add a blank line in output for readability.
    fprintf('\n')
end

%% denoiseSpeechBatch script

inputDir = "data/test/gabrielSamples/noisy";
outputDir = "data/test/gabrielSamples/output_wav";
% Define the directories for input noisy audio files and where to save the denoised output.

s = load("models/denoiseNet_FineTuned_VBD.mat");
denoiseNet = s.netFineTuned;
noisyMean = s.noisyMean;
noisyStd = s.noisyStd;
cleanMean = s.cleanMean;
cleanStd = s.cleanStd;
% Load the fine-tuned denoising neural network and associated normalization statistics.

win = hamming(256, "periodic");
overlap = round(0.75 * 256);
fftLength = 256;
numFeatures = fftLength / 2 + 1;
numSegments = 8;
targetFs = 8000;
% Set up the parameters for short-time Fourier transform (STFT) including windowing,
% overlap, FFT size, number of frequency bins, temporal context size, and target sample rate.

fileList = dir(fullfile(inputDir, '*.wav'));
% Get a list of all WAV audio files in the noisy input directory.

for k = 1:length(fileList)
    inputPath = fullfile(inputDir, fileList(k).name);
    [noisyAudio, fs] = audioread(inputPath);
    % Read the current noisy audio file and its sample rate.

    if size(noisyAudio, 2) > 1
        noisyAudio = mean(noisyAudio, 2);
        disp('Changed to mono')
    end
    % Convert stereo audio to mono by averaging the channels.

    if fs ~= targetFs
        disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)])
        noisyAudio = resample(noisyAudio, targetFs, fs);
        fs = targetFs;
    end
    % If the sample rate is not 8 kHz, resample the audio accordingly.

    noisySTFT = stft(noisyAudio, Window=win, OverlapLength=overlap, fftLength=fftLength);
    noisyPhase = angle(noisySTFT(numFeatures - 1:end, :));
    noisySTFT = abs(noisySTFT(numFeatures - 1:end, :));
    % Compute the STFT of the noisy signal, extract the phase for later reconstruction,
    % and reduce to the magnitude portion of the upper half of the spectrum.

    noisySTFT = [noisySTFT(:, 1:numSegments - 1), noisySTFT];
    numFrames = size(noisySTFT, 2) - numSegments + 1;
    predictors = zeros(129, numSegments, 1, numFrames);
    for idx = 1:numFrames
        predictors(:, :, 1, idx) = noisySTFT(:, idx:idx + numSegments - 1);
    end
    % Pad and slice the STFT magnitude into overlapping windows of 8 frames
    % to match the model's expected input dimensions.

    predictors(:) = (predictors(:) - noisyMean) / noisyStd;
    % Normalize the predictor input using the stored noisy training data mean and std.

    STFTDenoised = predict(denoiseNet, predictors);
    STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;
    STFTDenoised = STFTDenoised.'; 
    STFTDenoised = STFTDenoised .* exp(1j * noisyPhase);
    STFTDenoised = [conj(STFTDenoised(end - 1:-1:2, :)); STFTDenoised];
    % Denoise the input using the neural network. Then re-scale the output to original
    % clean data scale, restore the phase, and mirror the spectrum for inverse STFT.

    denoisedAudio = istft(STFTDenoised, Window=win, OverlapLength=overlap, fftLength=fftLength, ConjugateSymmetric=true);
    % Reconstruct the time-domain signal from the denoised complex spectrogram.

    [~, name, ~] = fileparts(fileList(k).name);
    outputName = strcat(name, '_dn.wav');
    outputPath = fullfile(outputDir, outputName);
    audiowrite(outputPath, denoisedAudio, fs);
    % Save the denoised audio as a new WAV file with "_dn" suffix.

    fprintf("Processed: %s → %s\n", fileList(k).name, outputName);
    % Display progress in the MATLAB console.
end

disp("All files denoised and saved.");
% Print a final message when all files are done.

