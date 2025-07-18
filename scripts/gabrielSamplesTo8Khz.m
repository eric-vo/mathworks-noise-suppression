% Base input/output folders
baseInputPath = 'data/test/gabrielSamples';
baseOutputPath = 'data/test/gabrielSamples';

% Folders to process
folders = {'clean', 'noisy'};

% Target sample rate
targetFs = 8000;

for j = 1:length(folders)
    % Define input and output folders for this group
    inputDir = fullfile(baseInputPath, folders{j});
    outputDir = fullfile(baseOutputPath, [folders{j}, '8Khz']);

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

fprintf('All files processed for clean and noisy folders.\n');
