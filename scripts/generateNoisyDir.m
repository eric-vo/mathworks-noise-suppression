function generateNoisyDir(clean_folder, noise_folder, output_folder)
% GENERATE_NOISY_DATASET
% Adds noise to each clean audio file using every noise file
% in the specified folders, saving the output to a target folder.
%
% This script loops through all clean and noise .wav files,
% applies the desired SNR, and saves the resulting noisy audio.

    % Desired Signal-to-Noise Ratio in dB
    snr_dB = 10;

    % Get list of clean audio files
    clean_files = dir(fullfile(clean_folder, '*.wav'));
    
    % Get list of noise files
    noise_files = dir(fullfile(noise_folder, '*.wav'));

    % Create output directory if it doesn't exist
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Loop through each combination of clean and noise
    for i = 1:length(clean_files)
        for j = 1:length(noise_files)
            clean_path = fullfile(clean_folder, clean_files(i).name);
            noise_path = fullfile(noise_folder, noise_files(j).name);

            % Create output filename
            clean_name = erase(clean_files(i).name, '.wav');
            noise_name = erase(noise_files(j).name, '.wav');
            output_filename = sprintf('%s_%s_%ddB.wav', clean_name, noise_name, snr_dB);
            output_path = fullfile(output_folder, output_filename);

            % Display progress status
            fprintf('Mixing %s + %s at %d dB SNR...\n', clean_files(i).name, noise_files(j).name, snr_dB);

            % Add noise and save
            generateNoisyFile(clean_path, noise_path, output_path, snr_dB);
        end
    end

    disp('All files processed and saved.');
end