function train(model, cleanDir, noisyDir, outputPath)
    % Load Previous Model and Stats
    s = load(model);

    [~, name, ~] = fileparts(model);
    if name == "denoiseNetFullyConnected"  
         net = s.denoiseNetFullyConnected; % For original pre-trained model
    else
        net = s.netFineTuned; % For fine-tuned model
    end

    noisyMean = s.noisyMean;
    noisyStd = s.noisyStd;
    cleanMean = s.cleanMean;
    cleanStd = s.cleanStd;

    fileList = dir(fullfile(noisyDir, '*.wav'));
    
    XTrain = {};
    YTrain = {};
    
    for i = 1:length(fileList)
        filename = fileList(i).name;
        noisyPath = fullfile(noisyDir, filename);
        cleanPath = fullfile(cleanDir, filename);
        if ~isfile(cleanPath)
            warning("Missing clean file: %s", filename);
            continue;
        end
        [X, Y] = createTrainingPair(noisyPath, cleanPath, noisyMean, noisyStd, cleanMean, cleanStd);
        XTrain{end+1} = X;
        YTrain{end+1} = Y;
    end
    
    X = cat(4, XTrain{:});
    Y = cat(2, YTrain{:});
    
    % Fine-Tune Network
    
    % Convert SeriesNetwork to trainable layerGraph and fix missing output
    layers = net.Layers;
    layers(end+1) = regressionLayer('Name','output');
    
    Y = reshape(Y, [129, 1, 1, size(Y, 2)]);  % Now: [129, 1, 1, N]
    Y = permute(Y, [2, 3, 1, 4]);  % Now: [1, 1, 129, N]
    
    options = trainingOptions('adam', ...
        'InitialLearnRate',1e-4, ...
        'MaxEpochs',5, ...
        'MiniBatchSize',64, ...
        'Shuffle','every-epoch', ...
        'Plots','training-progress', ...
        'Verbose',true, ExecutionEnvironment='gpu'); % Remove ExecutionEnvironment = 'gpu' if running on system w/o compatible NVIDIA GPU
    netFineTuned = trainNetwork(X, Y, layers, options);
    
    % Save Model
    save(outputPath, 'netFineTuned', 'noisyMean', 'noisyStd', 'cleanMean', 'cleanStd');
end
%%
% Function to Create Paired Training Data
function [X, Y] = createTrainingPair(noisyPath, cleanPath, noisyMean, noisyStd, cleanMean, cleanStd)
    [noisy, fs1] = audioread(noisyPath);
    [clean, fs2] = audioread(cleanPath);
    targetFs = 8000;
    if fs1 ~= targetFs
        noisy = resample(noisy, targetFs, fs1);
    end
    if fs2 ~= targetFs
        clean = resample(clean, targetFs, fs2);
    end
    noisy = mean(noisy, 2);
    clean = mean(clean, 2);
    minLen = min(length(noisy), length(clean));
    noisy = noisy(1:minLen);
    clean = clean(1:minLen);

    win = hamming(256, "periodic");
    overlap = round(0.75 * 256);
    fftLength = 256;
    numFeatures = fftLength / 2 + 1;

    noisySTFT = stft(noisy, Window=win, OverlapLength=overlap, fftLength=fftLength);
    cleanSTFT = stft(clean, Window=win, OverlapLength=overlap, fftLength=fftLength);

    noisySTFT = abs(noisySTFT(numFeatures-1:end,:));
    cleanSTFT = abs(cleanSTFT(numFeatures-1:end,:));

    numSegments = 8;
    noisySTFT = [noisySTFT(:,1:numSegments-1), noisySTFT];
    cleanSTFT = [cleanSTFT(:,1:numSegments-1), cleanSTFT];

    numFrames = size(noisySTFT,2) - numSegments + 1;
    X = zeros(129, numSegments, 1, numFrames);
    Y = zeros(129, numFrames);

    for i = 1:numFrames
        X(:,:,1,i) = noisySTFT(:, i:i+numSegments-1);
        Y(:,i) = cleanSTFT(:, i+numSegments-1);
    end

    X(:) = (X(:) - noisyMean) / noisyStd;
    Y(:) = (Y(:) - cleanMean) / cleanStd;
end

%[appendix]{"version":"1.0"}
%---
