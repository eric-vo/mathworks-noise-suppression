# mathworks-noise-suppression

%% calculateAudioError Script

function errorMetrics = calculateAudioError(cleanAudio, denoisedAudio)
% CALCULATEAUDIOERROR Calculate various error metrics between clean and denoised audio
% Input:
%   cleanAudio - Original clean audio signal
%   denoisedAudio - Denoised audio signal

% Output:

%   errorMetrics - Structure containing various error metrics

% Ensure both signals have the same length
minLength = min(length(cleanAudio), length(denoisedAudio));
cleanAudio = cleanAudio(1:minLength);
denoisedAudio = denoisedAudio(1:minLength);

% Calculate squared differences
squaredDifferences = (cleanAudio - denoisedAudio).^2;

% RMSE (Root Mean Square Error)
rmse_error = sqrt(mean(squaredDifferences));

% SNR in dB
signal_power = mean(cleanAudio.^2);
noise_power = mean(squaredDifferences);
snr_db = 10 * log10(signal_power / noise_power);
clean_rms = sqrt(mean(cleanAudio.^2));
nrmse_error = rmse_error / clean_rms;

% PSNR (Peak Signal-to-Noise Ratio)
max_signal = max(abs(cleanAudio));
psnr_db = 20 * log10(max_signal / rmse_error);

% Correlation coefficient
correlation_value = correlation(1,2);

% Store results
errorMetrics = struct();
errorMetrics.RMSE = rmse_error;
errorMetrics.MSE = mse_error;
errorMetrics.SNR_dB = snr_db;
errorMetrics.NRMSE = nrmse_error;
errorMetrics.PSNR_dB = psnr_db;
errorMetrics.MAE = mae_error;
errorMetrics.Correlation = correlation_value;

% Display results
fprintf('=== Audio Error Metrics ===\n');
fprintf('RMSE: %.6f\n', rmse_error);
fprintf('MSE: %.6f\n', mse_error);
fprintf('SNR: %.2f dB\n', snr_db);
fprintf('PSNR: %.2f dB\n', psnr_db);
fprintf('MAE: %.6f\n', mae_error);
fprintf('Correlation: %.6f\n', correlation_value);
end
