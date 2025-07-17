% This file has 2 functions: One function to process one file, another function to process an entire directory

function denoisedAudio = denoiseSpeechFile(noisyInput, outputDir)
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
    % denoiseNet = s.denoiseNetFullyConnected; % For original pre-trained model
    
    s = load("models/denoiseNet_FineTuned_VBD.mat");
    denoiseNet = s.netFineTuned; % For fine-tuned model
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
    outputPath = fullfile(outputDir, outputName);
    audiowrite(outputPath, denoisedAudio, fs);
    % sound(denoisedAudio, fs);
end
%%

function denoisedAudioArray = denoiseSpeechDir(noisyInputDir, outputDir)
    fileList = dir(fullfile(noisyInputDir, '*.wav'));
    numFiles = length(fileList);
    denoisedAudioArray = cell(1, numFiles);
    for i = 1:numFiles
        inputFile = fullfile(noisyInputDir, fileList(i).name);
        denoisedAudioArray{i} = denoiseSpeechFile(inputFile, outputDir);
    end
end
%%
% denoisedAudio = denoiseSpeechFile("data/test/simpleTest/noisyAudio.wav", "data/test/simpleTest/testOutput"); % will be moved to main.m in future
%%
% This block should be done in main.m
% [cleanAudio, ~] = audioread("SpeechDFT-16-8-mono-5secs.wav");
% soundsc(cleanAudio)
% pause(5)

% Calculate error metrics
% errorMetrics = calculateAudioError(cleanAudio, denoisedAudio); % should be done in main.m file
%%
denoisedAudioArray = denoiseSpeechDir("data/test/simpleTest/noisyInput", "data/test/simpleTest/testOutput");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":42.9}
%---
