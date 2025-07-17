cleanOriginalDir = "data/test/gabrielSamples/clean";
% AFTER RUNNING generate_noisy_dataset(cleanOriginalDir, noisedDir) ==> modify so it takes input/output directories
noisyInputDir = "data/test/gabrielSamples/noisy";
denoisedOutputDir = "data/test/gabrielSamples/output_wav";
%%
denoisedAudioArray = denoiseSpeechDir(noisyInputDir, denoisedOutputDir);

% GOAL: errorMetrics = calculateAvgCorrelation(denoisedAudioArray, cleanOriginalDir)

% This may be a lot easier if we reformat our clean/noisy directories to
% be in pairs, rather than a 1:10 ratio of clean:noisy files (so that the
% function doesn't have to be modified for different ratios of clean:noisy)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":26.5}
%---
