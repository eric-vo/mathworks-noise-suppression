function generateNoisyDir(cleanInputDir, noiseDir, noisedOutputDir, options)
% generateNoisyDir  Adds noise to each clean audio file using every noise file.
%
%   generateNoisyDir(cleanInputDir, noiseDir, noisedOutputDir, options)
%
%   This function loops through all .wav files in the clean input directory
%   and adds each noise file from the noise directory at the specified SNR.
%   Each resulting noisy file is saved in the output directory with a
%   descriptive filename.
%
%   Inputs:
%       cleanInputDir    - String, path to folder containing clean .wav files
%       noiseDir         - String, path to folder containing noise .wav files
%       noisedOutputDir  - String, path where the noisy files will be saved
%
%   Optional Name-Value Arguments (inside `options`):
%       snr_dB           - Numeric, desired SNR in decibels (default: 10)
%       clear            - Boolean, whether to clear the output directory before saving (default: true)
%
%   Notes:
%       - Output filenames are formatted as <cleanName>_<noiseName>_<SNR>dB.wav
%       - Output directory will be created if it doesn't exist
%       - Requires `generateNoisyFile` to be in the path

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
