% This file has 2 functions: One function to process one file, another function to process an entire directory
%%
function denoisedAudioArray = denoiseSpeechDir(model, noisyInputDir, denoisedOutputDir, options)
% denoiseSpeechDir  Denoises all .wav files in a directory using a deep learning model.
%
%   denoisedAudioArray = denoiseSpeechDir(model, noisyInputDir, denoisedOutputDir, options)
%
%   Applies a speech denoising model to every .wav file in a directory.
%   Uses `denoiseSpeechFile` for individual file processing and returns a
%   cell array of the denoised audio signals.
%
%   Inputs:
%       model              - Path to .mat file containing the trained denoising model
%       noisyInputDir      - Path to folder containing noisy .wav files
%       denoisedOutputDir  - Path to folder where denoised files will be saved
%
%   Optional Name-Value Arguments (in `options` struct):
%       clear              - Boolean (default: true), whether to clear the output directory before saving
%
%   Output:
%       denoisedAudioArray - Cell array where each element contains the denoised audio vector
%
%   Notes:
%       - Requires denoiseSpeechFile to be defined and in the path
%       - Assumes .wav filenames start with a number for proper sorting

    arguments
        model
        noisyInputDir
        denoisedOutputDir
        options.clear = 1
    end

    % Get all .wav files in the input directory
    fileList = dir(fullfile(noisyInputDir, '*.wav'));

    % Clear output directory
    if options.clear
        delete(denoisedOutputDir + "/*");
    end

    % Extract numeric part from each filename ***FIX***
    fileNums = arrayfun(@(f) sscanf(f.name, '%d'), fileList);

    % Sort files by numeric value in ascending order
    [~, sortIdx] = sort(fileNums, 'ascend');
    sortedFiles = fileList(sortIdx);

    numFiles = length(sortedFiles);
    denoisedAudioArray = cell(1, numFiles);

    % Denoise each file in sorted order
    for i = 1:numFiles
        inputFile = fullfile(noisyInputDir, sortedFiles(i).name);
        denoisedAudioArray{i} = denoiseSpeechFile(model, inputFile, denoisedOutputDir);
    end
end

%[appendix]{"version":"1.0"}
%---
