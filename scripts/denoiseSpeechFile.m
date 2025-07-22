function denoisedAudio = denoiseSpeechFile(model, noisyInput, denoisedOutputDir)
% denoiseSpeechFile  Applies a deep learning model to denoise a single noisy audio file.
%
%   denoisedAudio = denoiseSpeechFile(model, noisyInput, denoisedOutputDir)
%
%   This function loads a noisy speech audio file, preprocesses it with STFT,
%   applies a pre-trained or fine-tuned denoising neural network, reconstructs
%   the time-domain audio, and saves the denoised output.
%
%   Inputs:
%       model              - Path to .mat file containing the pre-trained or fine-tuned model
%       noisyInput         - Path to a single noisy .wav file
%       denoisedOutputDir  - Path to directory where denoised output will be saved
%
%   Output:
%       denoisedAudio      - Vector of denoised time-domain audio samples
%
%   Notes:
%       - Assumes model contains: netFineTuned (or denoiseNetFullyConnected), noisyMean, noisyStd, cleanMean, cleanStd
%       - Resamples audio to 8 kHz if necessary
%       - Saves output as <original_filename>_dn.wav in the specified directory

    % Load a noisy speech audio file
    [noisyAudio, fs] = audioread(noisyInput);
    % soundsc(noisyAudio)
    % pause(5)

    % Convert to mono if needed
    if size(noisyAudio,2) > 1
        noisyAudio = mean(noisyAudio, 2);
        % disp('Changed to mono')
    end
    
    % Resample to 8 kHz
    targetFs = 8000;
    if fs ~= targetFs
        % disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)])
        noisyAudio = resample(noisyAudio, targetFs, fs);
        fs = targetFs;
    end
    
    % Load a denoising network
    % s = load("models/denoiseNetFullyConnected.mat");
    s = load(model);
    [~, name, ~] = fileparts(model);
    if name == "denoiseNetFullyConnected"
         denoiseNet = s.denoiseNetFullyConnected; % For original pre-trained model
    else
        denoiseNet = s.netFineTuned; % For fine-tuned model
    end

    noisyMean = s.noisyMean;
    noisyStd = s.noisyStd;
    cleanMean = s.cleanMean;
    cleanStd = s.cleanStd;
    
    % Preprocess: Compute STFT
    win = hamming(256,"periodic");
    overlap = round(0.75*256);
    fftLength = 256;
    numFeatures = fftLength/2 + 1;
    
    noisySTFT = stft(noisyAudio, Window=win, OverlapLength=overlap, fftLength=fftLength);
    noisyPhase = angle(noisySTFT(numFeatures-1:end,:)); % Changed from 1:129
    noisySTFT = abs(noisySTFT(numFeatures-1:end,:)); % Changed from 1:129
    
    % Prepare predictors (8-segment context)
    numSegments = 8;
    noisySTFT = [noisySTFT(:,1:numSegments-1), noisySTFT];
    predictors = zeros(129, numSegments, size(noisySTFT,2) - numSegments + 1);
    for idx = 1:(size(noisySTFT,2) - numSegments + 1)
        predictors(:,:,idx) = noisySTFT(:,idx:idx + numSegments - 1);
    end
    
    % Normalize predictors
    predictors(:) = (predictors(:) - noisyMean) / noisyStd;
    predictors = reshape(predictors, [129, numSegments, 1, size(predictors,3)]);
    
    % Denoise using the network
    STFTDenoised = predict(denoiseNet, predictors);
    STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;
    STFTDenoised = STFTDenoised.'; % Transpose to match phase dimensions
    STFTDenoised = STFTDenoised.*exp(1j*noisyPhase);
    STFTDenoised = [conj(STFTDenoised(end-1:-1:2,:)); STFTDenoised];
    denoisedAudio = istft(STFTDenoised, Window=win, OverlapLength=overlap, fftLength=fftLength, ConjugateSymmetric=true);
    
    % Save or play the result
    [~, name, ~] = fileparts(noisyInput);
    outputName = strcat(name, '_dn.wav');
    outputPath = fullfile(denoisedOutputDir, outputName);
    audiowrite(outputPath, denoisedAudio, fs);
    % sound(denoisedAudio, fs);
end
