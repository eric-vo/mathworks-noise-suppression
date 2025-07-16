inputDir = "data/test/gabrielSamples/noisy";
outputDir = "data/test/gabrielSamples/output_wav";
%%
% Load fine-tuned model
s = load("models/denoiseNet_FineTuned_VBD.mat");
denoiseNet = s.netFineTuned;
noisyMean = s.noisyMean;
noisyStd = s.noisyStd;
cleanMean = s.cleanMean;
cleanStd = s.cleanStd;

% Setup Parameters for STFT
win = hamming(256,"periodic");
overlap = round(0.75*256);
fftLength = 256;
numFeatures = fftLength/2 + 1; % ADD THIS LINE
numSegments = 8;
targetFs = 8000;
%%
% Process all .wav files in inputDir
fileList = dir(fullfile(inputDir, '*.wav'));

for k = 1:length(fileList) %[output:group:729f5b56]
    % Input file path
    inputPath = fullfile(inputDir, fileList(k).name);

    % Load a noisy speech audio file
    [noisyAudio, fs] = audioread(inputPath);
    %soundsc(noisyAudio)
    
    % Convert to mono if needed
    if size(noisyAudio,2) > 1
        noisyAudio = mean(noisyAudio, 2);
        disp('Changed to mono')
    end
    
    % Resample if needed - Use 8 kHz
    if fs ~= targetFs
        disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)]) %[output:83407ad3] %[output:63e75418] %[output:9f1801e7] %[output:6721c40a] %[output:59778d40] %[output:2328ac88] %[output:5bfc2e52] %[output:4aa071d5] %[output:60fcbf36] %[output:0ff352ce] %[output:823f92d9] %[output:8ba64e7c] %[output:2935dfeb] %[output:090f569b] %[output:3d59bc10] %[output:67b8de9c] %[output:898a02d6] %[output:058a24d4] %[output:9ebfbce5] %[output:9e485455] %[output:68064f2d] %[output:44652f54] %[output:41a2c878] %[output:17185868] %[output:7eaff610] %[output:2d7afd94] %[output:753dacd7] %[output:3a2fa8d9] %[output:935a4ae3] %[output:2a8cb372] %[output:79929698] %[output:8dbef679] %[output:6b534a87] %[output:1eec02e2] %[output:2f93c9a2] %[output:8d221b1f] %[output:11acd0ee] %[output:2108f216] %[output:8ca5311b] %[output:70866de4] %[output:9231bf87] %[output:0ca376ce] %[output:24597f90] %[output:1419604d] %[output:88c383ce] %[output:1321b348] %[output:0a346625] %[output:35fcdacf] %[output:7d6f0bc0] %[output:5107151b] %[output:5749fe89] %[output:7afb4323] %[output:7118e474] %[output:121501cf] %[output:72af20d6] %[output:4859ec3a] %[output:85a0c268] %[output:91a33676] %[output:557ed672] %[output:98b0e85c] %[output:55ba3d2d] %[output:96e60280] %[output:01c5db91] %[output:18629516] %[output:2649050f] %[output:58d203a3] %[output:877516ca] %[output:008d3533] %[output:4e1b502f] %[output:06f17e44] %[output:4b1483aa] %[output:22061250] %[output:8c0cd023] %[output:73494466] %[output:9f5bf5d2] %[output:4f2acda3] %[output:58a805be] %[output:4c332a03] %[output:565a22d3] %[output:353b0d4c] %[output:19c75bc4] %[output:3da9de7f] %[output:5649ee43] %[output:4e2b044d] %[output:63736161] %[output:86a1362f] %[output:8c8f69e7] %[output:0d7f79b6] %[output:746ac443] %[output:1b2524e5] %[output:072060cf] %[output:59e2f95a] %[output:1ef52d87] %[output:0b70f9bc] %[output:46302742] %[output:241527d5] %[output:30f5ecf1] %[output:9909cf1f] %[output:56972689] %[output:1e8a249d]
        noisyAudio = resample(noisyAudio, targetFs, fs);
        fs = targetFs;
    end
    
    % Compute STFT
    noisySTFT = stft(noisyAudio, Window=win, OverlapLength=overlap, fftLength=fftLength);
    noisyPhase = angle(noisySTFT(numFeatures-1:end,:));
    noisySTFT = abs(noisySTFT(numFeatures-1:end,:));

    % Prepare predictors (8-segment context)
    noisySTFT = [noisySTFT(:,1:numSegments-1), noisySTFT];
    numFrames = size(noisySTFT, 2) - numSegments + 1;
    predictors = zeros(129, numSegments, 1, numFrames);
    for idx = 1:numFrames
        predictors(:,:,idx) = noisySTFT(:,idx:idx + numSegments - 1);
    end

    % Normalize predictors
    predictors(:) = (predictors(:) - noisyMean) / noisyStd;
    %predictors = reshape(predictors, [129, numSegments, 1, size(predictors,3)]);

    % Denoise
    STFTDenoised = predict(denoiseNet, predictors);
    STFTDenoised(:) = cleanStd * STFTDenoised(:) + cleanMean;
    STFTDenoised = STFTDenoised.'; % Transpose to match phase dimensions
    STFTDenoised = STFTDenoised.*exp(1j*noisyPhase);
    STFTDenoised = [conj(STFTDenoised(end-1:-1:2,:)); STFTDenoised];
    
    % Inverse STFT
    denoisedAudio = istft(STFTDenoised, Window=win, OverlapLength=overlap, fftLength=fftLength, ConjugateSymmetric=true);

    % Save denoised .wav file
    [~, name, ~] = fileparts(fileList(k).name);
    outputName = strcat(name, '_dn.wav');
    outputPath = fullfile(outputDir, outputName);
    audiowrite(outputPath, denoisedAudio, fs);

    % Show Progress
    fprintf("Processed: %s → %s\n", fileList(k).name, outputName); %[output:1f277474] %[output:8b1df211] %[output:97ac84e9] %[output:6eb53ea6] %[output:3d75f531] %[output:52fe014c] %[output:5c1a4c84] %[output:9d8c3b92] %[output:2cdc9a10] %[output:8276e1b4] %[output:61855931] %[output:2604cbdd] %[output:24e7d489] %[output:29973582] %[output:377842b9] %[output:1ac97cbd] %[output:9505449d] %[output:82a5b541] %[output:5e907dd9] %[output:47e5710b] %[output:2b8fcc75] %[output:4b2a697b] %[output:8e8230d7] %[output:05920efe] %[output:6d24b6ea] %[output:01821c7e] %[output:4e534663] %[output:847f1e8d] %[output:01c93950] %[output:79d323eb] %[output:84e834cd] %[output:2c2a046f] %[output:8e5b44de] %[output:91303209] %[output:5d863c62] %[output:4a46cc66] %[output:23a77a25] %[output:87cdb3e7] %[output:08e0728f] %[output:44d0e928] %[output:35fc44be] %[output:5a8c509d] %[output:4b456a9c] %[output:89bf0754] %[output:9b5f80e6] %[output:2ce5981b] %[output:942405fa] %[output:8f538de0] %[output:516a0a85] %[output:5fd23c1c] %[output:747144a5] %[output:16e72d47] %[output:175f04c8] %[output:6a54f0e7] %[output:1664a57f] %[output:213090bb] %[output:4681ec98] %[output:7e5bdecf] %[output:1ecd3cac] %[output:7c6ffb11] %[output:89e87f1a] %[output:37d3973f] %[output:6fe5eb0f] %[output:50ca71af] %[output:481e05f7] %[output:6da9069c] %[output:7f666d16] %[output:1a921638] %[output:6ba60848] %[output:78251b9d] %[output:0a2542c4] %[output:978c83bd] %[output:11b09b14] %[output:0412ebb2] %[output:6e469ad0] %[output:88b32731] %[output:4406fe6b] %[output:07f70824] %[output:5b5a278e] %[output:70b2ddb8] %[output:6bda967a] %[output:79c4fb54] %[output:77d23841] %[output:6283d1c5] %[output:847a0561] %[output:0dc29a6b] %[output:6fb1d167] %[output:9380fb24] %[output:67a62f5b] %[output:289f67e9] %[output:09d9b617] %[output:84df254c] %[output:82508852] %[output:601bb922] %[output:8bb7c2cc] %[output:089fd700] %[output:94204274] %[output:289b9ad6] %[output:82908732] %[output:2e1f237c]
end %[output:group:729f5b56]
%%
disp("All files denoised and saved."); %[output:39e86cea]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":33.7}
%---
%[output:83407ad3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1f277474]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_birds_farm_10dB.wav → 10_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:63e75418]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8b1df211]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_birds_farm_5dB.wav → 10_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:9f1801e7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:97ac84e9]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_cafe_10dB.wav → 10_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:6721c40a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6eb53ea6]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_cafe_5dB.wav → 10_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:59778d40]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3d75f531]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_jet_city_birds_10dB.wav → 10_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:2328ac88]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:52fe014c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_jet_city_birds_5dB.wav → 10_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:5bfc2e52]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5c1a4c84]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_pencils_10dB.wav → 10_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:4aa071d5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9d8c3b92]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_pencils_5dB.wav → 10_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:60fcbf36]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2cdc9a10]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_waves_10dB.wav → 10_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:0ff352ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8276e1b4]
%   data: {"dataType":"text","outputData":{"text":"Processed: 10_waves_5dB.wav → 10_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:823f92d9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:61855931]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_birds_farm_10dB.wav → 1_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:8ba64e7c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2604cbdd]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_birds_farm_5dB.wav → 1_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:2935dfeb]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:24e7d489]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_cafe_10dB.wav → 1_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:090f569b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:29973582]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_cafe_5dB.wav → 1_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:3d59bc10]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:377842b9]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_jet_city_birds_10dB.wav → 1_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:67b8de9c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1ac97cbd]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_jet_city_birds_5dB.wav → 1_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:898a02d6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9505449d]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_pencils_10dB.wav → 1_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:058a24d4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:82a5b541]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_pencils_5dB.wav → 1_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:9ebfbce5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5e907dd9]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_waves_10dB.wav → 1_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:9e485455]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:47e5710b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 1_waves_5dB.wav → 1_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:68064f2d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2b8fcc75]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_birds_farm_10dB.wav → 2_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:44652f54]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4b2a697b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_birds_farm_5dB.wav → 2_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:41a2c878]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e8230d7]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_cafe_10dB.wav → 2_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:17185868]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:05920efe]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_cafe_5dB.wav → 2_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:7eaff610]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6d24b6ea]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_jet_city_birds_10dB.wav → 2_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:2d7afd94]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:01821c7e]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_jet_city_birds_5dB.wav → 2_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:753dacd7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4e534663]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_pencils_10dB.wav → 2_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:3a2fa8d9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:847f1e8d]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_pencils_5dB.wav → 2_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:935a4ae3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:01c93950]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_waves_10dB.wav → 2_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:2a8cb372]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:79d323eb]
%   data: {"dataType":"text","outputData":{"text":"Processed: 2_waves_5dB.wav → 2_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:79929698]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:84e834cd]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_birds_farm_10dB.wav → 3_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:8dbef679]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2c2a046f]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_birds_farm_5dB.wav → 3_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:6b534a87]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e5b44de]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_cafe_10dB.wav → 3_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:1eec02e2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:91303209]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_cafe_5dB.wav → 3_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:2f93c9a2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5d863c62]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_jet_city_birds_10dB.wav → 3_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:8d221b1f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4a46cc66]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_jet_city_birds_5dB.wav → 3_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:11acd0ee]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:23a77a25]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_pencils_10dB.wav → 3_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:2108f216]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:87cdb3e7]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_pencils_5dB.wav → 3_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:8ca5311b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:08e0728f]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_waves_10dB.wav → 3_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:70866de4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:44d0e928]
%   data: {"dataType":"text","outputData":{"text":"Processed: 3_waves_5dB.wav → 3_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:9231bf87]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:35fc44be]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_birds_farm_10dB.wav → 4_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:0ca376ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5a8c509d]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_birds_farm_5dB.wav → 4_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:24597f90]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4b456a9c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_cafe_10dB.wav → 4_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:1419604d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:89bf0754]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_cafe_5dB.wav → 4_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:88c383ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9b5f80e6]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_jet_city_birds_10dB.wav → 4_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:1321b348]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2ce5981b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_jet_city_birds_5dB.wav → 4_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:0a346625]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:942405fa]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_pencils_10dB.wav → 4_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:35fcdacf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8f538de0]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_pencils_5dB.wav → 4_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:7d6f0bc0]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:516a0a85]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_waves_10dB.wav → 4_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:5107151b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5fd23c1c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 4_waves_5dB.wav → 4_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:5749fe89]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:747144a5]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_birds_farm_10dB.wav → 5_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:7afb4323]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:16e72d47]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_birds_farm_5dB.wav → 5_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:7118e474]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:175f04c8]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_cafe_10dB.wav → 5_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:121501cf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6a54f0e7]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_cafe_5dB.wav → 5_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:72af20d6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1664a57f]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_jet_city_birds_10dB.wav → 5_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:4859ec3a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:213090bb]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_jet_city_birds_5dB.wav → 5_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:85a0c268]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4681ec98]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_pencils_10dB.wav → 5_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:91a33676]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7e5bdecf]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_pencils_5dB.wav → 5_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:557ed672]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1ecd3cac]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_waves_10dB.wav → 5_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:98b0e85c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7c6ffb11]
%   data: {"dataType":"text","outputData":{"text":"Processed: 5_waves_5dB.wav → 5_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:55ba3d2d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:89e87f1a]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_birds_farm_10dB.wav → 6_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:96e60280]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:37d3973f]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_birds_farm_5dB.wav → 6_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:01c5db91]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6fe5eb0f]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_cafe_10dB.wav → 6_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:18629516]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:50ca71af]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_cafe_5dB.wav → 6_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:2649050f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:481e05f7]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_jet_city_birds_10dB.wav → 6_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:58d203a3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6da9069c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_jet_city_birds_5dB.wav → 6_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:877516ca]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7f666d16]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_pencils_10dB.wav → 6_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:008d3533]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1a921638]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_pencils_5dB.wav → 6_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:4e1b502f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6ba60848]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_waves_10dB.wav → 6_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:06f17e44]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:78251b9d]
%   data: {"dataType":"text","outputData":{"text":"Processed: 6_waves_5dB.wav → 6_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:4b1483aa]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0a2542c4]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_birds_farm_10dB.wav → 7_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:22061250]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:978c83bd]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_birds_farm_5dB.wav → 7_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:8c0cd023]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:11b09b14]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_cafe_10dB.wav → 7_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:73494466]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0412ebb2]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_cafe_5dB.wav → 7_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:9f5bf5d2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6e469ad0]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_jet_city_birds_10dB.wav → 7_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:4f2acda3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:88b32731]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_jet_city_birds_5dB.wav → 7_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:58a805be]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4406fe6b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_pencils_10dB.wav → 7_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:4c332a03]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:07f70824]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_pencils_5dB.wav → 7_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:565a22d3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5b5a278e]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_waves_10dB.wav → 7_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:353b0d4c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:70b2ddb8]
%   data: {"dataType":"text","outputData":{"text":"Processed: 7_waves_5dB.wav → 7_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:19c75bc4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6bda967a]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_birds_farm_10dB.wav → 8_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:3da9de7f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:79c4fb54]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_birds_farm_5dB.wav → 8_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:5649ee43]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:77d23841]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_cafe_10dB.wav → 8_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:4e2b044d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6283d1c5]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_cafe_5dB.wav → 8_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:63736161]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:847a0561]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_jet_city_birds_10dB.wav → 8_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:86a1362f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0dc29a6b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_jet_city_birds_5dB.wav → 8_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:8c8f69e7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6fb1d167]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_pencils_10dB.wav → 8_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:0d7f79b6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9380fb24]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_pencils_5dB.wav → 8_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:746ac443]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:67a62f5b]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_waves_10dB.wav → 8_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:1b2524e5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:289f67e9]
%   data: {"dataType":"text","outputData":{"text":"Processed: 8_waves_5dB.wav → 8_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:072060cf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:09d9b617]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_birds_farm_10dB.wav → 9_birds_farm_10dB_dn.wav\n","truncated":false}}
%---
%[output:59e2f95a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:84df254c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_birds_farm_5dB.wav → 9_birds_farm_5dB_dn.wav\n","truncated":false}}
%---
%[output:1ef52d87]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:82508852]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_cafe_10dB.wav → 9_cafe_10dB_dn.wav\n","truncated":false}}
%---
%[output:0b70f9bc]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:601bb922]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_cafe_5dB.wav → 9_cafe_5dB_dn.wav\n","truncated":false}}
%---
%[output:46302742]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8bb7c2cc]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_jet_city_birds_10dB.wav → 9_jet_city_birds_10dB_dn.wav\n","truncated":false}}
%---
%[output:241527d5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:089fd700]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_jet_city_birds_5dB.wav → 9_jet_city_birds_5dB_dn.wav\n","truncated":false}}
%---
%[output:30f5ecf1]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:94204274]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_pencils_10dB.wav → 9_pencils_10dB_dn.wav\n","truncated":false}}
%---
%[output:9909cf1f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:289b9ad6]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_pencils_5dB.wav → 9_pencils_5dB_dn.wav\n","truncated":false}}
%---
%[output:56972689]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:82908732]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_waves_10dB.wav → 9_waves_10dB_dn.wav\n","truncated":false}}
%---
%[output:1e8a249d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2e1f237c]
%   data: {"dataType":"text","outputData":{"text":"Processed: 9_waves_5dB.wav → 9_waves_5dB_dn.wav\n","truncated":false}}
%---
%[output:39e86cea]
%   data: {"dataType":"text","outputData":{"text":"All files denoised and saved.\n","truncated":false}}
%---
