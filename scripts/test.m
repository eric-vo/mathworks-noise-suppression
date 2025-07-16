% Set root paths and parameters
cleanDir = '../data/test/gabrielSamples/clean';
noisyDir = '../data/test/gabrielSamples/noisy';
outDir = '../testDenoised';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
numClean = 10;
numNoisy = 5;

% Load denoising model and normalization stats
s = load("../models/denoiseNet_FineTuned_VBD.mat");
denoiseNet = s.netFineTuned;
noisyMean = s.noisyMean;
noisyStd = s.noisyStd;
cleanMean = s.cleanMean;
cleanStd = s.cleanStd;

% Prepare output matrix
correlationVals = zeros(numClean, numNoisy);

% Loop over clean files
for i = 1:numClean
    cleanFile = fullfile(cleanDir, sprintf('%d.wav', i));
    [cleanAudio, fs] = audioread(cleanFile);
    
    for j = 1:numNoisy
        % Find the relevant noisy file. Use wildcard for <xx>.
        pattern = sprintf('%d_*.wav', i);
        files = dir(fullfile(noisyDir, pattern));
        % Defensive: Ensure at least five noisy files exist per clean
        if numel(files) < numNoisy
            error('Not enough noisy files for clean file %d', i);
        end
        noisyFile = fullfile(noisyDir, files(j).name);

        % Print progress
        fprintf('Processing clean file %d, noisy version %d: %s\n', i, j, files(j).name);

        % Read and denoise
        [noisyAudio, ~] = audioread(noisyFile);
        if size(noisyAudio,2) > 1
            noisyAudio = mean(noisyAudio, 2);
        end
        
        % Preprocess and STFT
        win = hamming(256, 'periodic');
        overlap = round(0.75 * 256);
        fftLength = 256;
        numFeatures = fftLength/2 + 1;
        noisySTFT = stft(noisyAudio, 'Window', win, 'OverlapLength', overlap, 'FFTLength', fftLength);
        noisyPhase = angle(noisySTFT(numFeatures-1:end, :));
        magNoisySTFT = abs(noisySTFT(numFeatures-1:end, :));
        
        % Prepare context for predictors
        numSegments = 8;
        magNoisySTFT = [magNoisySTFT(:,1:numSegments-1), magNoisySTFT];
        predictors = zeros(129, numSegments, size(magNoisySTFT,2) - numSegments + 1);
        for idx = 1:(size(magNoisySTFT,2) - numSegments + 1)
            predictors(:,:,idx) = magNoisySTFT(:,idx:idx + numSegments - 1);
        end
        predictors(:) = (predictors(:) - noisyMean) / noisyStd;
        predictors = reshape(predictors, [129, numSegments, 1, size(predictors,3)]);
        
        % Denoise using the pre-trained network
        STFTDenoised = predict(denoiseNet, predictors);
        STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;
        STFTDenoised = STFTDenoised.';
        STFTDenoised = STFTDenoised .* exp(1j*noisyPhase);

        % Ensure conjugate symmetry & reconstruct
        STFTDenoisedFull = [conj(STFTDenoised(end-1:-1:2,:)); STFTDenoised];
        denoisedAudio = istft(STFTDenoisedFull, 'Window', win, 'OverlapLength', overlap, 'FFTLength', fftLength, 'ConjugateSymmetric', true);

        % Store denoised file
        [~, noisyName, ~] = fileparts(files(j).name);
        outName = sprintf('%d_%d_denoised.wav', i, j);
        audiowrite(fullfile(outDir, outName), denoisedAudio, fs);

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
