function errorMetrics = calculateAudioError(cleanAudio, denoisedAudio)
% CALCULATEAUDIOERROR Calculate multiple error metrics between clean and denoised audio signals
%
%   errorMetrics = calculateAudioError(cleanAudio, denoisedAudio)
%
%   Computes a set of common audio quality metrics to evaluate how close a denoised
%   signal is to a clean reference signal. Assumes both inputs are mono and aligned in time.
%
%   Inputs:
%       cleanAudio     - Vector of clean/reference audio samples
%       denoisedAudio  - Vector of denoised audio samples to compare
%
%   Output:
%       errorMetrics   - Struct containing:
%           .RMSE        - Root Mean Square Error
%           .MSE         - Mean Squared Error
%           .SNR_dB      - Signal-to-Noise Ratio in decibels
%           .NRMSE       - Normalized RMSE (by RMS of clean audio)
%           .PSNR_dB     - Peak Signal-to-Noise Ratio in dB
%           .MAE         - Mean Absolute Error
%           .Correlation - Pearson correlation coefficient between signals
%
%   Notes:
%       - The function truncates the longer signal if inputs are not the same length.
%       - It also prints the metrics to the console.

    % Ensure both signals have the same length
    minLength = min(length(cleanAudio), length(denoisedAudio));
    cleanAudio = cleanAudio(1:minLength);
    denoisedAudio = denoisedAudio(1:minLength);
    
    % Calculate squared differences
    squaredDifferences = (cleanAudio - denoisedAudio).^2;
    
    % RMSE (Root Mean Square Error)
    rmse_error = sqrt(mean(squaredDifferences));
    
    % MSE (Mean Squared Error)
    mse_error = mean(squaredDifferences);
    
    % SNR in dB
    signal_power = mean(cleanAudio.^2);
    noise_power = mean(squaredDifferences);
    snr_db = 10 * log10(signal_power / noise_power);
    
    % NRMSE (Normalized RMSE)
    clean_rms = sqrt(mean(cleanAudio.^2));
    nrmse_error = rmse_error / clean_rms;
    
    % PSNR (Peak Signal-to-Noise Ratio)
    max_signal = max(abs(cleanAudio));
    psnr_db = 20 * log10(max_signal / rmse_error);
    
    % MAE (Mean Absolute Error)
    mae_error = mean(abs(cleanAudio - denoisedAudio));
    
    % Correlation coefficient
    correlation = corrcoef(cleanAudio, denoisedAudio);
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
    fprintf('NRMSE: %.6f\n', nrmse_error);
    fprintf('PSNR: %.2f dB\n', psnr_db);
    fprintf('MAE: %.6f\n', mae_error);
    fprintf('Correlation: %.6f\n', correlation_value);
end
