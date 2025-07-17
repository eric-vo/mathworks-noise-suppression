function generate_noisy_dataset()
% GENERATE_NOISY_DATASET
% Adds noise to each clean audio file using every noise file
% in the specified folders, saving the output to a target folder.
%
% This script loops through all clean and noise .wav files,
% applies the desired SNR, and saves the resulting noisy audio.

    % Desired Signal-to-Noise Ratio in dB
    snr_dB = 10;  

    % Define folder paths
    clean_folder = '../data/test/gabrielSamples/clean/';
    noise_folder = '../data/noise/';
    output_folder = '../data/test/gabrielSamples/noisy/';

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
            add_noise(clean_path, noise_path, output_path, snr_dB);
        end
    end

    disp('All files processed and saved.');
end


function noisy = add_noise(clean_path, noise_path, output_path, snr_dB)
% ADD_NOISE Adds noise to a clean audio file at a specific SNR (dB)
% 
% Receives:
%   clean_path  - string, path to clean speech .wav file
%   noise_path  - string, path to noise-only .wav file
%   output_path - string, where to save the resulting noisy audio
%   snr_dB      - numeric value, desired Signal-to-Noise Ratio in dB
%
% Returns:
%   noisy       - vector, resulting noisy audio signal

    % Load audio files
    [clean, fs1] = audioread(clean_path);
    [noise, fs2] = audioread(noise_path);

    % Convert to mono if stereo
    if size(clean, 2) > 1
        clean = mean(clean, 2);
    end
    if size(noise, 2) > 1
        noise = mean(noise, 2);
    end

    % Resample noise to match clean if needed
    if fs1 ~= fs2
        noise = resample(noise, fs1, fs2);
    end

    % Trim or repeat noise to match clean length
    if length(noise) < length(clean)
        noise = repmat(noise, ceil(length(clean)/length(noise)), 1);
    end
    noise = noise(1:length(clean));

    % Compute power (mean squared value)
    clean_power = mean(clean .^ 2);
    noise_power = mean(noise .^ 2);

    % Calculate scaling factor based on SNR
    snr_linear = 10^(snr_dB / 10);
    scale = sqrt(clean_power / (snr_linear * noise_power));

    % Apply scaling to noise
    noise_scaled = noise * scale;

    % Add noise to clean signal
    noisy = clean + noise_scaled;

    % Normalize output to avoid clipping
    max_val = max(abs(noisy));
    if max_val > 1
        noisy = noisy / max_val;
    end

    % Save result
    audiowrite(output_path, noisy, fs1);
end