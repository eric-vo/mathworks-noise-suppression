# Speech Noise Suppression with Deep Learning in MATLAB
## by Eric Vo, Kailash Rao, Siwoo Chung, Gabriel Ramos

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=eric-vo/mathworks-ai-challenge&file=scripts/main.m)

**Demo:** https://www.youtube.com/watch?v=eTR514DVRlk

---

## Overview

This project fine-tunes and analyzes a deep learning model for speech noise suppression using MATLAB, Audio Toolbox, and Deep Learning Toolbox. The goal was to develop a denoising system that improves speech quality in noisy environments and evaluate its effectiveness using both:

- **Subjective methods** – human-rated clarity  
- **Objective metrics** – quantitative performance (SNR, RMSE, correlation, etc.)

---

## Running the Project

**Run `main.m` after adding `scripts/` to your MATLAB path.**  
It will:

- Load the fine-tuned model  
- Add noise to custom audio samples  
- Denoise the samples using the model  
- Compute correlation and SNR improvement between clean, noisy, and denoised audio  

---

## Project Timeline

**Time Frame:** 6/27/2025 – 7/18/2025 (3 weeks)

- Conducted a literature review on deep learning-based speech noise suppression  
- Downloaded/curated datasets (VoiceBank-Demand, MATLAB demo sets)  
- Generated noisy samples using custom noise at various SNR levels  
- Fine-tuned a pre-trained model on VoiceBank-Demand samples  
- Applied STFT preprocessing and neural network inference  
- Evaluated denoising performance via:  
  - Subjective listening tests (clarity scale: 1–5)  
  - Objective metrics (RMSE, SNR, correlation, PSNR, etc.)

---

## Results

**Objective Results**

- **Average Correlation:** `0.9435`  
- **Average SNR Improvement:** `+6.84 dB` *(example value; update with actual)*

**Subjective Ratings** (from `data/test/gabrielSamples/output_wav/`):

| File                          | Clarity (1–5) |
|-------------------------------|---------------|
| `10_waves_5dB_dn.wav`         | 3.7           |
| `10_pencils_5dB_dn.wav`       | 3.2           |
| `10_jet_city_birds_5db_dn.wav`| 3.0           |
| `10_cafe_5db_dn.wav`          | 2.8           |
| `10_birds_farm_5db_dn.wav`    | 3.2           |

---

## Model & Features

- **Model:** Fine-tuned from MATLAB's pre-trained `denoiseNetFullyConnected`  
- **Training Data:** VoiceBank-Demand Dataset (VBD)  
- **Preprocessing:** STFT with Hamming windows  
- **Feature Context:** 8-segment windows  
- **Sampling Rate:** 8 kHz  

---

## Folder Structure

```
data/
├── test/
│   └── gabrielSamples/
│       ├── clean/             # Ground truth clean audio files
│       ├── noise/             # Background noise samples (e.g., birds, cafe, jet)
│       ├── noisy/             # Generated noisy files (via generateNoisyDir)
│       ├── output_wav/        # Final denoised audio results (_dn.wav)
│       └── subjective/        # Resampled files used in clarity rating tests

models/
└── denoiseNet_FineTuned_VBD.mat  # Fine-tuned deep learning model

scripts/
├── main.m                     # Top-level driver script
├── generateNoisyFile.m       # Adds noise to one file
├── generateNoisyDir.m        # Adds noise to a directory of files
├── denoiseSpeechFile.m       # Denoises one noisy input
├── denoiseSpeechDir.m        # Denoises a batch of inputs
├── calculateAudioError.m     # Computes SNR, RMSE, etc.
├── calculateCorrelationDir.m # Calculates correlation across batch
└── calculateSNRImprovementDir.m # Computes SNR improvement vs. noisy baseline
```

---

## Key Scripts

**main.m**  
- Top-level runner that integrates training, denoising, and evaluation.

**Audio Processing**
- `generateNoisyFile` – Mixes clean + noise at target SNR  
- `generateNoisyDir` – Batch version of above  
- `denoiseSpeechFile` – Applies model to single noisy file  
- `denoiseSpeechDir` – Applies model to directory of noisy files  

**Evaluation & Metrics**
- `calculateAudioError` – Computes RMSE, SNR, PSNR, correlation, MAE  
- `calculateCorrelationDir` – Correlation matrix across test set  
- `calculateSNRImprovementDir` – SNR improvement from noisy → denoised  

---

## Dependencies

- MATLAB R2025a or later  
- Audio Toolbox  
- Deep Learning Toolbox  
- Signal Processing Toolbox  

---

## Contributors

| Name           | Contributions                                      |
|----------------|-----------------------------------------------------|
| Siwoo Chung    | Model tuning, script development                   |
| Kailash Rao    | STFT/ISTFT testing, AI training, script development |
| Eric Vo        | Script development, objective evaluation           |
| Gabriel Ramos  | Dataset preparation, README documentation          |

---

## License

This project was created for the **MathWorks AI Noise Suppression Challenge**.  
Use is restricted to **academic and non-commercial purposes only**.  
No license file currently provided.

