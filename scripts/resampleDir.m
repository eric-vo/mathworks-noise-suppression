function resampleDir(inputDir, outputDir, targetFs)
    % resampleDir  Resamples all WAV files in a directory to a target sampling rate.
    %
    %   resampleDir(inputDir, outputDir, targetFs)
    %
    %   This function reads all .wav files in the input directory, checks their
    %   sampling rate, resamples them if needed to match the specified target
    %   sampling frequency, and writes the result to the output directory.
    %
    %   Inputs:
    %       inputDir   - Path to the input directory containing .wav files
    %       outputDir  - Path to the output directory to save resampled files
    %       targetFs   - Target sampling frequency in Hz (e.g., 8000)
    %
    %   Notes:
    %       - Files with the correct sampling rate are copied directly.
    %       - Output directory will be created if it does not exist.
    %       - Overwrites files with the same name in the output directory.

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
