% test_add_noise.m
snr_dB = 5;  % Desired Signal-to-Noise Ratio in decibels

clean_path = '../data/clean/1.wav';
noise_path = '../data/noise/cafe.wav';
output_path = '../data/output/noisy_mix.wav';

disp(['Mixing clean + noise at ' num2str(snr_dB) ' dB SNR...']);

add_noise(clean_path, noise_path, output_path, snr_dB);

disp('Done! Noisy file saved.');
