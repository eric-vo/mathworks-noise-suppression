function noisy = add_noise(clean_path, noise_path, output_path, snr_dB)
    % Load audio files
    [clean, fs1] = audioread(clean_path);
    [noise, fs2] = audioread(noise_path);
    
    % Resample noise if needed
    if fs1 ~= fs2
        noise = resample(noise, fs1, fs2);
    end

    % Trim or loop noise to match clean length
    if length(noise) < length(clean)
        noise = repmat(noise, ceil(length(clean)/length(noise)), 1);
    end
    noise = noise(1:length(clean));

    % Normalize both
    clean = clean / norm(clean);
    noise = noise / norm(noise);

    % Mix with target SNR
    snr_linear = 10^(snr_dB/20);
    noisy = clean + (1/snr_linear)*noise;
    noisy = noisy / max(abs(noisy)); % prevent clipping

    % Save output
    if nargin == 4
        audiowrite(output_path, noisy, fs1);
    end
end
