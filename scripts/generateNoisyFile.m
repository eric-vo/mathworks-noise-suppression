function noisyAudio = generateNoisyFile(clean_path, noise_path, output_path, snr_dB)
% generateNoisyFile  Adds background noise to a clean audio file at a specified SNR.
%
%   noisyAudio = generateNoisyFile(clean_path, noise_path, output_path, snr_dB)
%
%   Loads a clean speech file and a noise file, scales the noise to achieve
%   the desired Signal-to-Noise Ratio (SNR), mixes them, normalizes the result,
%   and writes the noisy audio to the specified output path.
%
%   Inputs:
%       clean_path   - String, path to clean speech .wav file
%       noise_path   - String, path to noise-only .wav file
%       output_path  - String, path to save the resulting noisy .wav file
%       snr_dB       - Numeric value, desired SNR in decibels
%
%   Output:
%       noisyAudio   - Vector, resulting noisy audio signal

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
    noisyAudio = clean + noise_scaled;

    % Normalize output to avoid clipping
    max_val = max(abs(noisyAudio));
    if max_val > 1
        noisyAudio = noisyAudio / max_val;
    end

    % Save result
    audiowrite(output_path, noisyAudio, fs1);
end
