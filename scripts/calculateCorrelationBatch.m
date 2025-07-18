function [correlations, avgCorr] = calculateCorrelationBatch(denoisedAudioArray, cleanOriginalDir)
    numClean = 10;
    numDenoised = 10;
    
    targetFs = 8000;
    
    % Prepare output matrix
    correlations = zeros(numClean, numDenoised);
    
    % Loop over clean files
    for i = 1:numClean
        cleanFile = fullfile(cleanOriginalDir, sprintf('%d.wav', i));
        [cleanAudio, cleanFs] = audioread(cleanFile);
    
        % Resample if needed - Use 8 kHz
        if cleanFs ~= targetFs
            cleanAudio = resample(cleanAudio, targetFs, cleanFs);
        end
        
        for j = 1:numDenoised
            % Print progress
            fprintf('Processing clean file %d, denoised version %d\n', i, j);
    
            % Read and denoise
            denoisedAudio = denoisedAudioArray{(i - 1) * 10 + j};
            if size(denoisedAudio, 2) > 1
                denoisedAudio = mean(denoisedAudio, 2);
            end
    
            % Compute error metrics
            errorMetrics = calculateAudioError(cleanAudio, denoisedAudio);
            correlations(i,j) = errorMetrics.Correlation;
    
            fprintf('\n')
        end
    end
    
    for i = 1:numClean
        % Print correlation values for this clean file
        fprintf('Correlation values for clean file %d: ', i);
        fprintf('%.4f ', correlations(i,:));
        fprintf('\n');
    end
    
    % Print overall average correlation
    avgCorr = mean(correlations(:));
    fprintf('Average correlation across all files: %.4f\n', avgCorr);
end
