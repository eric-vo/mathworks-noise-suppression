inputDir = "data/test/datasetSamples/noisy_testset_wav";
outputDir = "data/test/datasetSamples/output_wav";
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
        disp(['Changed sample rate from ' num2str(fs) ' to ' num2str(targetFs)]) %[output:83407ad3] %[output:63e75418] %[output:9f1801e7] %[output:6721c40a] %[output:59778d40] %[output:2328ac88] %[output:5bfc2e52] %[output:4aa071d5] %[output:60fcbf36] %[output:0ff352ce] %[output:823f92d9] %[output:8ba64e7c] %[output:2935dfeb] %[output:090f569b] %[output:3d59bc10] %[output:67b8de9c] %[output:898a02d6] %[output:058a24d4] %[output:9ebfbce5] %[output:9e485455] %[output:68064f2d] %[output:44652f54] %[output:41a2c878] %[output:17185868] %[output:7eaff610] %[output:2d7afd94] %[output:753dacd7] %[output:3a2fa8d9] %[output:935a4ae3] %[output:2a8cb372] %[output:79929698] %[output:8dbef679] %[output:6b534a87] %[output:1eec02e2] %[output:2f93c9a2] %[output:8d221b1f] %[output:11acd0ee] %[output:2108f216] %[output:8ca5311b] %[output:70866de4] %[output:9231bf87] %[output:0ca376ce] %[output:24597f90] %[output:1419604d] %[output:88c383ce] %[output:1321b348] %[output:0a346625] %[output:35fcdacf] %[output:7d6f0bc0] %[output:5107151b] %[output:5749fe89] %[output:20accd30] %[output:5afd504c] %[output:22ccb094] %[output:23f0c2f2] %[output:0595a462] %[output:1bc213e5] %[output:01317a42] %[output:13f7277e] %[output:4d83fc27] %[output:25bd5f10] %[output:6274f623] %[output:12df2e85] %[output:5b02e81c] %[output:546a5b37] %[output:794dd250] %[output:0a25dffc] %[output:8236b278] %[output:189e431b] %[output:4402c348] %[output:8b708639] %[output:03324787] %[output:63135dc1] %[output:02cdd960] %[output:1644b829] %[output:08639758] %[output:226d3015] %[output:3a3bc56b] %[output:854d3630] %[output:73eb2d3d] %[output:57868c81] %[output:1acde1a8] %[output:6a2198ae] %[output:0538a5a9] %[output:001beaaf] %[output:4047598f] %[output:2ca676a3] %[output:4bc51e55] %[output:317440c8] %[output:627579c0] %[output:990f7476] %[output:237e12a5] %[output:05968481] %[output:0bd6972f] %[output:98dfa445] %[output:713c7cbf] %[output:0a7c98ee] %[output:9a529fdd] %[output:065914d1] %[output:51021a69] %[output:8473954b] %[output:4c525ff9] %[output:1b4530ee] %[output:66ce24e7] %[output:72b3bbff] %[output:5e507442] %[output:908cc9f4] %[output:6b63c0ac] %[output:9000463b] %[output:3b5d664a] %[output:36b3ffb9] %[output:2aa65de2] %[output:539822d6] %[output:73d14c42] %[output:9ad48216] %[output:30081030] %[output:0621bf3c] %[output:04471b51] %[output:24abc7ac] %[output:189ba186] %[output:16c92fb1] %[output:710c438d] %[output:253de797] %[output:0af82b96] %[output:3cb33172] %[output:5a37f385] %[output:732232bf] %[output:5ac69c1a] %[output:6eb34b76] %[output:44cf7a63] %[output:056b7025] %[output:113b5e39] %[output:256104a8] %[output:1c2a60a0] %[output:25fc47b6] %[output:03865972] %[output:832e1b1f] %[output:6b7f986e] %[output:3fb78f8d] %[output:04f5524f] %[output:25220298] %[output:7ef36165] %[output:35c1ed9d] %[output:0fb3e9b2] %[output:1f4648b2] %[output:7910170b] %[output:11c56197] %[output:5cf829b2] %[output:9501c793] %[output:67eed5b5] %[output:116912f9] %[output:8c3e1922] %[output:5847d556] %[output:882f90c8] %[output:08700ccd] %[output:36a16046] %[output:406c778c] %[output:573f2117] %[output:0d6c745c] %[output:7bbce22d] %[output:6d3b9db6] %[output:7919290b] %[output:47063115] %[output:22b6cab0] %[output:33fe945b] %[output:87be436d] %[output:4d0e96a2] %[output:1b0c76bc] %[output:0cf803ee] %[output:17d4e802] %[output:39c57b08] %[output:4bf38797] %[output:8614a8bd] %[output:5c5a5249] %[output:6ef64c1c] %[output:95898582] %[output:15f6daef] %[output:80e14315] %[output:3649c1e2] %[output:2426ecab] %[output:68a36bb3] %[output:1e6b7197] %[output:59b2527f] %[output:31b60043] %[output:128792c4] %[output:4168c64a] %[output:52855c01] %[output:4772e9fe] %[output:301e9e91] %[output:77d8ce71] %[output:19aa9bca] %[output:836b690b] %[output:05ac1ec4]
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
    fprintf("Processed: %s → %s\n", fileList(k).name, outputName); %[output:1f277474] %[output:8b1df211] %[output:97ac84e9] %[output:6eb53ea6] %[output:3d75f531] %[output:52fe014c] %[output:5c1a4c84] %[output:9d8c3b92] %[output:2cdc9a10] %[output:8276e1b4] %[output:61855931] %[output:2604cbdd] %[output:24e7d489] %[output:29973582] %[output:377842b9] %[output:1ac97cbd] %[output:9505449d] %[output:82a5b541] %[output:5e907dd9] %[output:47e5710b] %[output:2b8fcc75] %[output:4b2a697b] %[output:8e8230d7] %[output:05920efe] %[output:6d24b6ea] %[output:01821c7e] %[output:4e534663] %[output:847f1e8d] %[output:01c93950] %[output:79d323eb] %[output:84e834cd] %[output:2c2a046f] %[output:8e5b44de] %[output:91303209] %[output:5d863c62] %[output:4a46cc66] %[output:23a77a25] %[output:87cdb3e7] %[output:08e0728f] %[output:44d0e928] %[output:35fc44be] %[output:5a8c509d] %[output:4b456a9c] %[output:89bf0754] %[output:9b5f80e6] %[output:2ce5981b] %[output:942405fa] %[output:8f538de0] %[output:516a0a85] %[output:5fd23c1c] %[output:50133b7d] %[output:1c4c2649] %[output:76f0c634] %[output:91f88bca] %[output:372c73ae] %[output:56a567a4] %[output:447d0247] %[output:211e9e7d] %[output:36f0b566] %[output:28c99f95] %[output:40b03df2] %[output:222110de] %[output:72008ef8] %[output:2fdb62c0] %[output:8373224b] %[output:840f7e27] %[output:43274369] %[output:3c03a7c2] %[output:20409989] %[output:3fbd171f] %[output:21d17eee] %[output:4644df7b] %[output:89b11d01] %[output:0aaa688d] %[output:7a1b8f15] %[output:169efcce] %[output:03b0fe22] %[output:3377b3f9] %[output:1454d945] %[output:24284c4d] %[output:5123332e] %[output:528657d2] %[output:5a2b91f1] %[output:47928bf3] %[output:7a50cb19] %[output:51261234] %[output:0f7f95c4] %[output:97733afb] %[output:6d8347ab] %[output:9e62bbf7] %[output:78277474] %[output:33b2b367] %[output:5d2d8256] %[output:0ff0c1be] %[output:43a3dc95] %[output:09b0611a] %[output:2aaf2f5f] %[output:922d4ec6] %[output:6c258c04] %[output:7b0244f8] %[output:61efbe80] %[output:49a78c25] %[output:06ca92a3] %[output:6bacd125] %[output:273a4b65] %[output:26d0bcaa] %[output:619f51ee] %[output:0922670d] %[output:085374bc] %[output:813c594b] %[output:033d8466] %[output:07f92eb8] %[output:7492c831] %[output:1a2543c7] %[output:29e9cf4a] %[output:6689bd96] %[output:394ba84d] %[output:02e1de54] %[output:1c30ac2e] %[output:94ec0860] %[output:98c3d244] %[output:6c00d8bd] %[output:0645cafd] %[output:66001d2e] %[output:8241c7f5] %[output:97b9850c] %[output:3fb3b1f8] %[output:17da3e18] %[output:6a4b4f15] %[output:2d18f753] %[output:11c31ee8] %[output:012f2681] %[output:8e6d137a] %[output:128b704c] %[output:458a7382] %[output:70f3c4e6] %[output:3e156ea3] %[output:746f4e57] %[output:3e251624] %[output:195876b4] %[output:07da568e] %[output:6431a819] %[output:93eba2ae] %[output:827713c6] %[output:9b98f7f9] %[output:7dc59309] %[output:39739979] %[output:4e253c7d] %[output:4916a74d] %[output:06ef63b9] %[output:08b8bcd5] %[output:2a5a589d] %[output:2be16c98] %[output:2f60918a] %[output:58b5a90e] %[output:8e4adc7c] %[output:1ed5fe65] %[output:1ba4090c] %[output:18bde589] %[output:316c885a] %[output:4f8fad4a] %[output:88806562] %[output:21e35350] %[output:88ce4323] %[output:3c0230f7] %[output:7efc870f] %[output:4aa36fea] %[output:13f208da] %[output:96826a61] %[output:31b9fd35] %[output:74cdc75c] %[output:0d7f5449] %[output:9fcd6ecb] %[output:2488f2a1] %[output:48ef7033] %[output:6f1a1a2e] %[output:24f19374] %[output:7a08f9d8] %[output:5169917d] %[output:69b1a4ad] %[output:40e16912] %[output:892a0ae6] %[output:94dc93d8] %[output:79a94620] %[output:02da5152] %[output:4faad4e4] %[output:2c4a2169] %[output:8a619b07] %[output:4c821a08] %[output:16ffd7c7] %[output:27129d0b] %[output:25394efa] %[output:8c022996]
end %[output:group:729f5b56]
%%
disp("All files denoised and saved."); %[output:121b0a54]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":33.7}
%---
%[output:83407ad3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1f277474]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_326.wav → p232_326_dn.wav\n","truncated":false}}
%---
%[output:63e75418]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8b1df211]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_327.wav → p232_327_dn.wav\n","truncated":false}}
%---
%[output:9f1801e7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:97ac84e9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_328.wav → p232_328_dn.wav\n","truncated":false}}
%---
%[output:6721c40a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6eb53ea6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_329.wav → p232_329_dn.wav\n","truncated":false}}
%---
%[output:59778d40]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3d75f531]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_330.wav → p232_330_dn.wav\n","truncated":false}}
%---
%[output:2328ac88]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:52fe014c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_331.wav → p232_331_dn.wav\n","truncated":false}}
%---
%[output:5bfc2e52]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5c1a4c84]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_332.wav → p232_332_dn.wav\n","truncated":false}}
%---
%[output:4aa071d5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9d8c3b92]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_333.wav → p232_333_dn.wav\n","truncated":false}}
%---
%[output:60fcbf36]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2cdc9a10]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_334.wav → p232_334_dn.wav\n","truncated":false}}
%---
%[output:0ff352ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8276e1b4]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_335.wav → p232_335_dn.wav\n","truncated":false}}
%---
%[output:823f92d9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:61855931]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_336.wav → p232_336_dn.wav\n","truncated":false}}
%---
%[output:8ba64e7c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2604cbdd]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_337.wav → p232_337_dn.wav\n","truncated":false}}
%---
%[output:2935dfeb]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:24e7d489]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_338.wav → p232_338_dn.wav\n","truncated":false}}
%---
%[output:090f569b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:29973582]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_339.wav → p232_339_dn.wav\n","truncated":false}}
%---
%[output:3d59bc10]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:377842b9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_340.wav → p232_340_dn.wav\n","truncated":false}}
%---
%[output:67b8de9c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1ac97cbd]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_341.wav → p232_341_dn.wav\n","truncated":false}}
%---
%[output:898a02d6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9505449d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_342.wav → p232_342_dn.wav\n","truncated":false}}
%---
%[output:058a24d4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:82a5b541]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_343.wav → p232_343_dn.wav\n","truncated":false}}
%---
%[output:9ebfbce5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5e907dd9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_344.wav → p232_344_dn.wav\n","truncated":false}}
%---
%[output:9e485455]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:47e5710b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_346.wav → p232_346_dn.wav\n","truncated":false}}
%---
%[output:68064f2d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2b8fcc75]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_347.wav → p232_347_dn.wav\n","truncated":false}}
%---
%[output:44652f54]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4b2a697b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_348.wav → p232_348_dn.wav\n","truncated":false}}
%---
%[output:41a2c878]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e8230d7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_349.wav → p232_349_dn.wav\n","truncated":false}}
%---
%[output:17185868]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:05920efe]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_350.wav → p232_350_dn.wav\n","truncated":false}}
%---
%[output:7eaff610]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6d24b6ea]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_351.wav → p232_351_dn.wav\n","truncated":false}}
%---
%[output:2d7afd94]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:01821c7e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_352.wav → p232_352_dn.wav\n","truncated":false}}
%---
%[output:753dacd7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4e534663]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_353.wav → p232_353_dn.wav\n","truncated":false}}
%---
%[output:3a2fa8d9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:847f1e8d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_354.wav → p232_354_dn.wav\n","truncated":false}}
%---
%[output:935a4ae3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:01c93950]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_355.wav → p232_355_dn.wav\n","truncated":false}}
%---
%[output:2a8cb372]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:79d323eb]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_356.wav → p232_356_dn.wav\n","truncated":false}}
%---
%[output:79929698]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:84e834cd]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_357.wav → p232_357_dn.wav\n","truncated":false}}
%---
%[output:8dbef679]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2c2a046f]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_358.wav → p232_358_dn.wav\n","truncated":false}}
%---
%[output:6b534a87]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e5b44de]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_359.wav → p232_359_dn.wav\n","truncated":false}}
%---
%[output:1eec02e2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:91303209]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_360.wav → p232_360_dn.wav\n","truncated":false}}
%---
%[output:2f93c9a2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5d863c62]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_361.wav → p232_361_dn.wav\n","truncated":false}}
%---
%[output:8d221b1f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4a46cc66]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_362.wav → p232_362_dn.wav\n","truncated":false}}
%---
%[output:11acd0ee]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:23a77a25]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_363.wav → p232_363_dn.wav\n","truncated":false}}
%---
%[output:2108f216]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:87cdb3e7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_364.wav → p232_364_dn.wav\n","truncated":false}}
%---
%[output:8ca5311b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:08e0728f]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_365.wav → p232_365_dn.wav\n","truncated":false}}
%---
%[output:70866de4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:44d0e928]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_366.wav → p232_366_dn.wav\n","truncated":false}}
%---
%[output:9231bf87]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:35fc44be]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_367.wav → p232_367_dn.wav\n","truncated":false}}
%---
%[output:0ca376ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5a8c509d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_368.wav → p232_368_dn.wav\n","truncated":false}}
%---
%[output:24597f90]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4b456a9c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_369.wav → p232_369_dn.wav\n","truncated":false}}
%---
%[output:1419604d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:89bf0754]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_370.wav → p232_370_dn.wav\n","truncated":false}}
%---
%[output:88c383ce]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9b5f80e6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_371.wav → p232_371_dn.wav\n","truncated":false}}
%---
%[output:1321b348]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2ce5981b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_372.wav → p232_372_dn.wav\n","truncated":false}}
%---
%[output:0a346625]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:942405fa]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_373.wav → p232_373_dn.wav\n","truncated":false}}
%---
%[output:35fcdacf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8f538de0]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_374.wav → p232_374_dn.wav\n","truncated":false}}
%---
%[output:7d6f0bc0]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:516a0a85]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_375.wav → p232_375_dn.wav\n","truncated":false}}
%---
%[output:5107151b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5fd23c1c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_377.wav → p232_377_dn.wav\n","truncated":false}}
%---
%[output:5749fe89]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:50133b7d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_378.wav → p232_378_dn.wav\n","truncated":false}}
%---
%[output:20accd30]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1c4c2649]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_379.wav → p232_379_dn.wav\n","truncated":false}}
%---
%[output:5afd504c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:76f0c634]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_380.wav → p232_380_dn.wav\n","truncated":false}}
%---
%[output:22ccb094]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:91f88bca]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_381.wav → p232_381_dn.wav\n","truncated":false}}
%---
%[output:23f0c2f2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:372c73ae]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_382.wav → p232_382_dn.wav\n","truncated":false}}
%---
%[output:0595a462]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:56a567a4]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_383.wav → p232_383_dn.wav\n","truncated":false}}
%---
%[output:1bc213e5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:447d0247]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_384.wav → p232_384_dn.wav\n","truncated":false}}
%---
%[output:01317a42]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:211e9e7d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_385.wav → p232_385_dn.wav\n","truncated":false}}
%---
%[output:13f7277e]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:36f0b566]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_386.wav → p232_386_dn.wav\n","truncated":false}}
%---
%[output:4d83fc27]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:28c99f95]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_387.wav → p232_387_dn.wav\n","truncated":false}}
%---
%[output:25bd5f10]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:40b03df2]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_388.wav → p232_388_dn.wav\n","truncated":false}}
%---
%[output:6274f623]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:222110de]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_389.wav → p232_389_dn.wav\n","truncated":false}}
%---
%[output:12df2e85]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:72008ef8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_390.wav → p232_390_dn.wav\n","truncated":false}}
%---
%[output:5b02e81c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2fdb62c0]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_391.wav → p232_391_dn.wav\n","truncated":false}}
%---
%[output:546a5b37]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8373224b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_392.wav → p232_392_dn.wav\n","truncated":false}}
%---
%[output:794dd250]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:840f7e27]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_393.wav → p232_393_dn.wav\n","truncated":false}}
%---
%[output:0a25dffc]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:43274369]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_394.wav → p232_394_dn.wav\n","truncated":false}}
%---
%[output:8236b278]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3c03a7c2]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_396.wav → p232_396_dn.wav\n","truncated":false}}
%---
%[output:189e431b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:20409989]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_397.wav → p232_397_dn.wav\n","truncated":false}}
%---
%[output:4402c348]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3fbd171f]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_398.wav → p232_398_dn.wav\n","truncated":false}}
%---
%[output:8b708639]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:21d17eee]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_399.wav → p232_399_dn.wav\n","truncated":false}}
%---
%[output:03324787]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4644df7b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_400.wav → p232_400_dn.wav\n","truncated":false}}
%---
%[output:63135dc1]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:89b11d01]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_402.wav → p232_402_dn.wav\n","truncated":false}}
%---
%[output:02cdd960]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0aaa688d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_403.wav → p232_403_dn.wav\n","truncated":false}}
%---
%[output:1644b829]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7a1b8f15]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_404.wav → p232_404_dn.wav\n","truncated":false}}
%---
%[output:08639758]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:169efcce]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_405.wav → p232_405_dn.wav\n","truncated":false}}
%---
%[output:226d3015]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:03b0fe22]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_407.wav → p232_407_dn.wav\n","truncated":false}}
%---
%[output:3a3bc56b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3377b3f9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_409.wav → p232_409_dn.wav\n","truncated":false}}
%---
%[output:854d3630]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1454d945]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_410.wav → p232_410_dn.wav\n","truncated":false}}
%---
%[output:73eb2d3d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:24284c4d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_411.wav → p232_411_dn.wav\n","truncated":false}}
%---
%[output:57868c81]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5123332e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_412.wav → p232_412_dn.wav\n","truncated":false}}
%---
%[output:1acde1a8]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:528657d2]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_413.wav → p232_413_dn.wav\n","truncated":false}}
%---
%[output:6a2198ae]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5a2b91f1]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_414.wav → p232_414_dn.wav\n","truncated":false}}
%---
%[output:0538a5a9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:47928bf3]
%   data: {"dataType":"text","outputData":{"text":"Processed: p232_415.wav → p232_415_dn.wav\n","truncated":false}}
%---
%[output:001beaaf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7a50cb19]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_326.wav → p257_326_dn.wav\n","truncated":false}}
%---
%[output:4047598f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:51261234]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_327.wav → p257_327_dn.wav\n","truncated":false}}
%---
%[output:2ca676a3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0f7f95c4]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_328.wav → p257_328_dn.wav\n","truncated":false}}
%---
%[output:4bc51e55]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:97733afb]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_329.wav → p257_329_dn.wav\n","truncated":false}}
%---
%[output:317440c8]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6d8347ab]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_330.wav → p257_330_dn.wav\n","truncated":false}}
%---
%[output:627579c0]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9e62bbf7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_331.wav → p257_331_dn.wav\n","truncated":false}}
%---
%[output:990f7476]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:78277474]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_332.wav → p257_332_dn.wav\n","truncated":false}}
%---
%[output:237e12a5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:33b2b367]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_333.wav → p257_333_dn.wav\n","truncated":false}}
%---
%[output:05968481]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5d2d8256]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_334.wav → p257_334_dn.wav\n","truncated":false}}
%---
%[output:0bd6972f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0ff0c1be]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_335.wav → p257_335_dn.wav\n","truncated":false}}
%---
%[output:98dfa445]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:43a3dc95]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_336.wav → p257_336_dn.wav\n","truncated":false}}
%---
%[output:713c7cbf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:09b0611a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_337.wav → p257_337_dn.wav\n","truncated":false}}
%---
%[output:0a7c98ee]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2aaf2f5f]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_338.wav → p257_338_dn.wav\n","truncated":false}}
%---
%[output:9a529fdd]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:922d4ec6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_339.wav → p257_339_dn.wav\n","truncated":false}}
%---
%[output:065914d1]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6c258c04]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_340.wav → p257_340_dn.wav\n","truncated":false}}
%---
%[output:51021a69]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7b0244f8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_341.wav → p257_341_dn.wav\n","truncated":false}}
%---
%[output:8473954b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:61efbe80]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_342.wav → p257_342_dn.wav\n","truncated":false}}
%---
%[output:4c525ff9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:49a78c25]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_343.wav → p257_343_dn.wav\n","truncated":false}}
%---
%[output:1b4530ee]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:06ca92a3]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_344.wav → p257_344_dn.wav\n","truncated":false}}
%---
%[output:66ce24e7]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6bacd125]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_345.wav → p257_345_dn.wav\n","truncated":false}}
%---
%[output:72b3bbff]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:273a4b65]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_346.wav → p257_346_dn.wav\n","truncated":false}}
%---
%[output:5e507442]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:26d0bcaa]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_347.wav → p257_347_dn.wav\n","truncated":false}}
%---
%[output:908cc9f4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:619f51ee]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_348.wav → p257_348_dn.wav\n","truncated":false}}
%---
%[output:6b63c0ac]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0922670d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_349.wav → p257_349_dn.wav\n","truncated":false}}
%---
%[output:9000463b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:085374bc]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_350.wav → p257_350_dn.wav\n","truncated":false}}
%---
%[output:3b5d664a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:813c594b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_351.wav → p257_351_dn.wav\n","truncated":false}}
%---
%[output:36b3ffb9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:033d8466]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_352.wav → p257_352_dn.wav\n","truncated":false}}
%---
%[output:2aa65de2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:07f92eb8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_353.wav → p257_353_dn.wav\n","truncated":false}}
%---
%[output:539822d6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7492c831]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_354.wav → p257_354_dn.wav\n","truncated":false}}
%---
%[output:73d14c42]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1a2543c7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_355.wav → p257_355_dn.wav\n","truncated":false}}
%---
%[output:9ad48216]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:29e9cf4a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_356.wav → p257_356_dn.wav\n","truncated":false}}
%---
%[output:30081030]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6689bd96]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_357.wav → p257_357_dn.wav\n","truncated":false}}
%---
%[output:0621bf3c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:394ba84d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_358.wav → p257_358_dn.wav\n","truncated":false}}
%---
%[output:04471b51]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:02e1de54]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_359.wav → p257_359_dn.wav\n","truncated":false}}
%---
%[output:24abc7ac]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1c30ac2e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_360.wav → p257_360_dn.wav\n","truncated":false}}
%---
%[output:189ba186]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:94ec0860]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_361.wav → p257_361_dn.wav\n","truncated":false}}
%---
%[output:16c92fb1]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:98c3d244]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_362.wav → p257_362_dn.wav\n","truncated":false}}
%---
%[output:710c438d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6c00d8bd]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_363.wav → p257_363_dn.wav\n","truncated":false}}
%---
%[output:253de797]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0645cafd]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_364.wav → p257_364_dn.wav\n","truncated":false}}
%---
%[output:0af82b96]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:66001d2e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_365.wav → p257_365_dn.wav\n","truncated":false}}
%---
%[output:3cb33172]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8241c7f5]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_366.wav → p257_366_dn.wav\n","truncated":false}}
%---
%[output:5a37f385]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:97b9850c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_367.wav → p257_367_dn.wav\n","truncated":false}}
%---
%[output:732232bf]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3fb3b1f8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_368.wav → p257_368_dn.wav\n","truncated":false}}
%---
%[output:5ac69c1a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:17da3e18]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_369.wav → p257_369_dn.wav\n","truncated":false}}
%---
%[output:6eb34b76]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6a4b4f15]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_370.wav → p257_370_dn.wav\n","truncated":false}}
%---
%[output:44cf7a63]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2d18f753]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_371.wav → p257_371_dn.wav\n","truncated":false}}
%---
%[output:056b7025]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:11c31ee8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_372.wav → p257_372_dn.wav\n","truncated":false}}
%---
%[output:113b5e39]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:012f2681]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_373.wav → p257_373_dn.wav\n","truncated":false}}
%---
%[output:256104a8]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e6d137a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_374.wav → p257_374_dn.wav\n","truncated":false}}
%---
%[output:1c2a60a0]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:128b704c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_375.wav → p257_375_dn.wav\n","truncated":false}}
%---
%[output:25fc47b6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:458a7382]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_376.wav → p257_376_dn.wav\n","truncated":false}}
%---
%[output:03865972]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:70f3c4e6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_377.wav → p257_377_dn.wav\n","truncated":false}}
%---
%[output:832e1b1f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3e156ea3]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_378.wav → p257_378_dn.wav\n","truncated":false}}
%---
%[output:6b7f986e]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:746f4e57]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_379.wav → p257_379_dn.wav\n","truncated":false}}
%---
%[output:3fb78f8d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3e251624]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_380.wav → p257_380_dn.wav\n","truncated":false}}
%---
%[output:04f5524f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:195876b4]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_381.wav → p257_381_dn.wav\n","truncated":false}}
%---
%[output:25220298]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:07da568e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_382.wav → p257_382_dn.wav\n","truncated":false}}
%---
%[output:7ef36165]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6431a819]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_383.wav → p257_383_dn.wav\n","truncated":false}}
%---
%[output:35c1ed9d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:93eba2ae]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_384.wav → p257_384_dn.wav\n","truncated":false}}
%---
%[output:0fb3e9b2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:827713c6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_385.wav → p257_385_dn.wav\n","truncated":false}}
%---
%[output:1f4648b2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9b98f7f9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_386.wav → p257_386_dn.wav\n","truncated":false}}
%---
%[output:7910170b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7dc59309]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_387.wav → p257_387_dn.wav\n","truncated":false}}
%---
%[output:11c56197]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:39739979]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_388.wav → p257_388_dn.wav\n","truncated":false}}
%---
%[output:5cf829b2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4e253c7d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_389.wav → p257_389_dn.wav\n","truncated":false}}
%---
%[output:9501c793]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4916a74d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_390.wav → p257_390_dn.wav\n","truncated":false}}
%---
%[output:67eed5b5]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:06ef63b9]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_391.wav → p257_391_dn.wav\n","truncated":false}}
%---
%[output:116912f9]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:08b8bcd5]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_392.wav → p257_392_dn.wav\n","truncated":false}}
%---
%[output:8c3e1922]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2a5a589d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_393.wav → p257_393_dn.wav\n","truncated":false}}
%---
%[output:5847d556]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2be16c98]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_394.wav → p257_394_dn.wav\n","truncated":false}}
%---
%[output:882f90c8]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2f60918a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_395.wav → p257_395_dn.wav\n","truncated":false}}
%---
%[output:08700ccd]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:58b5a90e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_396.wav → p257_396_dn.wav\n","truncated":false}}
%---
%[output:36a16046]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8e4adc7c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_397.wav → p257_397_dn.wav\n","truncated":false}}
%---
%[output:406c778c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1ed5fe65]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_398.wav → p257_398_dn.wav\n","truncated":false}}
%---
%[output:573f2117]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:1ba4090c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_399.wav → p257_399_dn.wav\n","truncated":false}}
%---
%[output:0d6c745c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:18bde589]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_400.wav → p257_400_dn.wav\n","truncated":false}}
%---
%[output:7bbce22d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:316c885a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_401.wav → p257_401_dn.wav\n","truncated":false}}
%---
%[output:6d3b9db6]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4f8fad4a]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_402.wav → p257_402_dn.wav\n","truncated":false}}
%---
%[output:7919290b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:88806562]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_403.wav → p257_403_dn.wav\n","truncated":false}}
%---
%[output:47063115]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:21e35350]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_404.wav → p257_404_dn.wav\n","truncated":false}}
%---
%[output:22b6cab0]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:88ce4323]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_405.wav → p257_405_dn.wav\n","truncated":false}}
%---
%[output:33fe945b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:3c0230f7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_406.wav → p257_406_dn.wav\n","truncated":false}}
%---
%[output:87be436d]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7efc870f]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_407.wav → p257_407_dn.wav\n","truncated":false}}
%---
%[output:4d0e96a2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4aa36fea]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_408.wav → p257_408_dn.wav\n","truncated":false}}
%---
%[output:1b0c76bc]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:13f208da]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_409.wav → p257_409_dn.wav\n","truncated":false}}
%---
%[output:0cf803ee]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:96826a61]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_410.wav → p257_410_dn.wav\n","truncated":false}}
%---
%[output:17d4e802]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:31b9fd35]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_411.wav → p257_411_dn.wav\n","truncated":false}}
%---
%[output:39c57b08]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:74cdc75c]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_412.wav → p257_412_dn.wav\n","truncated":false}}
%---
%[output:4bf38797]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:0d7f5449]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_413.wav → p257_413_dn.wav\n","truncated":false}}
%---
%[output:8614a8bd]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:9fcd6ecb]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_414.wav → p257_414_dn.wav\n","truncated":false}}
%---
%[output:5c5a5249]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2488f2a1]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_415.wav → p257_415_dn.wav\n","truncated":false}}
%---
%[output:6ef64c1c]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:48ef7033]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_416.wav → p257_416_dn.wav\n","truncated":false}}
%---
%[output:95898582]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:6f1a1a2e]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_417.wav → p257_417_dn.wav\n","truncated":false}}
%---
%[output:15f6daef]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:24f19374]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_418.wav → p257_418_dn.wav\n","truncated":false}}
%---
%[output:80e14315]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:7a08f9d8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_419.wav → p257_419_dn.wav\n","truncated":false}}
%---
%[output:3649c1e2]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:5169917d]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_420.wav → p257_420_dn.wav\n","truncated":false}}
%---
%[output:2426ecab]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:69b1a4ad]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_421.wav → p257_421_dn.wav\n","truncated":false}}
%---
%[output:68a36bb3]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:40e16912]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_422.wav → p257_422_dn.wav\n","truncated":false}}
%---
%[output:1e6b7197]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:892a0ae6]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_423.wav → p257_423_dn.wav\n","truncated":false}}
%---
%[output:59b2527f]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:94dc93d8]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_424.wav → p257_424_dn.wav\n","truncated":false}}
%---
%[output:31b60043]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:79a94620]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_425.wav → p257_425_dn.wav\n","truncated":false}}
%---
%[output:128792c4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:02da5152]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_426.wav → p257_426_dn.wav\n","truncated":false}}
%---
%[output:4168c64a]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4faad4e4]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_427.wav → p257_427_dn.wav\n","truncated":false}}
%---
%[output:52855c01]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:2c4a2169]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_428.wav → p257_428_dn.wav\n","truncated":false}}
%---
%[output:4772e9fe]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8a619b07]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_429.wav → p257_429_dn.wav\n","truncated":false}}
%---
%[output:301e9e91]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:4c821a08]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_430.wav → p257_430_dn.wav\n","truncated":false}}
%---
%[output:77d8ce71]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:16ffd7c7]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_431.wav → p257_431_dn.wav\n","truncated":false}}
%---
%[output:19aa9bca]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:27129d0b]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_432.wav → p257_432_dn.wav\n","truncated":false}}
%---
%[output:836b690b]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:25394efa]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_433.wav → p257_433_dn.wav\n","truncated":false}}
%---
%[output:05ac1ec4]
%   data: {"dataType":"text","outputData":{"text":"Changed sample rate from 48000 to 8000\n","truncated":false}}
%---
%[output:8c022996]
%   data: {"dataType":"text","outputData":{"text":"Processed: p257_434.wav → p257_434_dn.wav\n","truncated":false}}
%---
%[output:121b0a54]
%   data: {"dataType":"text","outputData":{"text":"All files denoised and saved.\n","truncated":false}}
%---
