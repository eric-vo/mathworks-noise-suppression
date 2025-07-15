% test_add_noise.m

% Set SNR value
snr_dB = 5;

% Define input folders
clean_folder = '../data/test/gabrielSamples/clean/';
noise_folder = '../data/noise/';
output_folder = '../data/test/gabrielSamples/noisy/';

% Get list of clean audio files
clean_files = dir(fullfile(clean_folder, '*.wav'));

% Get list of noise files (now with your renamed files)
noise_files = dir(fullfile(noise_folder, '*.wav'));

% Make sure output folder exists
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Loop through each combination of clean and noise
for i = 1:length(clean_files)
    for j = 1:length(noise_files)
        clean_path = fullfile(clean_folder, clean_files(i).name);
        noise_path = fullfile(noise_folder, noise_files(j).name);
        
        % Generate output filename
        clean_name = erase(clean_files(i).name, '.wav');
        noise_name = erase(noise_files(j).name, '.wav');
        output_filename = sprintf('%s_%s_%ddB.wav', clean_name, noise_name, snr_dB);
        output_path = fullfile(output_folder, output_filename);

        % Display status
        fprintf('Mixing %s + %s at %d dB SNR...\n', clean_files(i).name, noise_files(j).name, snr_dB);

        % Call add_noise function
        add_noise(clean_path, noise_path, output_path, snr_dB);
    end
end

disp('All combinations processed and saved.');
