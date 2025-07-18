function resampleDir(inputDir, outputDir, targetFs)
    % Create output directory if it doesn't exist
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Get list of WAV files in this folder
    wavFiles = dir(fullfile(inputDir, '*.wav'));

    for i = 1:length(wavFiles)
        % Full path to input file
        inputFile = fullfile(inputDir, wavFiles(i).name);

        % Read audio
        [audioIn, originalFs] = audioread(inputFile);

        % Resample if needed
        if originalFs ~= targetFs
            audioOut = resample(audioIn, targetFs, originalFs);
        else
            audioOut = audioIn;
        end

        % Full path to output file
        outputFile = fullfile(outputDir, wavFiles(i).name);

        % Write resampled audio
        audiowrite(outputFile, audioOut, targetFs);

        fprintf('Resampled %s -> %s\n', inputFile, outputFile);
    end
end
