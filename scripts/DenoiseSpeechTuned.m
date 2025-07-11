% Load a noisy speech audio file
[noisyAudio, fs] = audioread("simple_test/p232_007.wav");
soundsc(noisyAudio)
%%
% Convert to mono if needed
if size(noisyAudio,2) > 1
    noisyAudio = mean(noisyAudio, 2);
    disp('Changed to mono')
end

% Resample if needed - Use 8 kHz
targetFs = 8000;
if fs ~= targetFs %[output:group:67b8d94c]
    disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)]) %[output:90a2d112]
    noisyAudio = resample(noisyAudio, targetFs, fs);
    fs = targetFs;
end %[output:group:67b8d94c]
%%
% Load a pre-trained denoising network (fully connected)
s = load("denoiseNet_FineTuned_VBD.mat");
denoiseNet = s.netFineTuned;
noisyMean = s.noisyMean;
noisyStd = s.noisyStd;
cleanMean = s.cleanMean;
cleanStd = s.cleanStd;

% Preprocess: Compute STFT
win = hamming(256,"periodic");
overlap = round(0.75*256);
fftLength = 256;
numFeatures = fftLength/2 + 1; % ADD THIS LINE
noisySTFT = stft(noisyAudio, Window=win, OverlapLength=overlap, fftLength=fftLength);

% FIXED: Correct frequency range indexing
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

% Denoise using the pre-trained network
STFTDenoised = predict(denoiseNet, predictors);

% FIXED: Rescale and reconstruct time-domain signal
STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;
STFTDenoised = STFTDenoised.'; % Transpose to match phase dimensions
STFTDenoised = STFTDenoised.*exp(1j*noisyPhase);
STFTDenoised = [conj(STFTDenoised(end-1:-1:2,:)); STFTDenoised];
denoisedAudio = istft(STFTDenoised, Window=win, OverlapLength=overlap, fftLength=fftLength, ConjugateSymmetric=true);
%%
% Save or play the result
audiowrite('denoisedSpeech.wav', denoisedAudio, fs);
sound(denoisedAudio, fs);

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":33.7}
%---
%[output:90a2d112]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
