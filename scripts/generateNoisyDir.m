function generateNoisyDir(cleanInputDir, noiseDir, noisedOutputDir, options)
% GENERATE NOISY DIR
% Adds noise to each clean audio file using every noise file
% in the specified folders, saving the output to a target folder.
%
% This script loops through all clean and noise .wav files,
% applies the desired SNR, and saves the resulting noisy audio.
    
    arguments
        cleanInputDir
        noiseDir
        noisedOutputDir
        options.snr_dB = 10
        options.clear = 1
    end

    % Get list of clean audio files
    cleanFiles = dir(fullfile(cleanInputDir, '*.wav'));
    
    % Get list of noise files
    noiseFiles = dir(fullfile(noiseDir, '*.wav'));

    % Create output directory if it doesn't exist
    if ~exist(noisedOutputDir, 'dir')
        mkdir(noisedOutputDir);
    end
    
    % Clear output directory
    if options.clear
        delete(noisedOutputDir + "/*");
    end

    % Loop through each combination of clean and noise
    for i = 1:length(cleanFiles)
        for j = 1:length(noiseFiles)
            cleanPath = fullfile(cleanInputDir, cleanFiles(i).name);
            noisePath = fullfile(noiseDir, noiseFiles(j).name);

            % Create output filename
            cleanName = erase(cleanFiles(i).name, '.wav');
            noiseName = erase(noiseFiles(j).name, '.wav');
            outputFilename = sprintf('%s_%s_%ddB.wav', cleanName, noiseName, options.snr_dB);
            outputPath = fullfile(noisedOutputDir, outputFilename);

            % Display progress status
            fprintf('Mixing %s + %s at %d dB SNR...\n', cleanFiles(i).name, noiseFiles(j).name, options.snr_dB);

            % Add noise and save
            generateNoisyFile(cleanPath, noisePath, outputPath, options.snr_dB);
        end
    end

    disp('All files processed and saved.');
end