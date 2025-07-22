% This file has 2 functions: One function to process one file, another function to process an entire directory
%%
function denoisedAudioArray = denoiseSpeechDir(model, noisyInputDir, denoisedOutputDir, options)

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
