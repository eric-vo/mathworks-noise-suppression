## Speech Noise Suppression with Deep Learning in MATLAB

## Overview
This project shows how to train and analyze a deep learning model for speech noise suppression with the use of MATLAB, "Audio Toolbox", and "Deep Learning Toolbox". The main goal was to develop a denoising system for which improved speech quality in noisy environments. Also to evaluate the effectiveness with the use of both subjective (our own weird human opinionated hearing) and objective (actual quantitative metrics) methods.

## Objectives
Conducted a literature review on deep learning-based speech noise suppression using MATLAB resources, as well as other open source resources.
Downloaded and prepared speech/noise datasets following the Microsoft DNS Challenge.
Designed and trained a deep learning denoising network by use of MATLAB.
Applied STFT signal processing techniques to prep data for training and inference.
Evaluated the performance by use of:
Subjective listening tests
Objective metrics

## Model and Feature Stuff
Model Type: Fine-tuned neural network (denoiseNet_FineTuned_VBD)
Preprocessing: STFT with Hamming windows
Feature Context: 8-segment context windows
Sampling Rate: 8 kHz

##  Project Structure

```
📁 data/
└── test/
    └── simpleTest/
        ├── noisyInput/
        └── testOutput/

📁 models/
└── denoiseNet_FineTuned_VBD.mat

📄 calculateAudioError.m
📄 calculateCorrelationBatch.m
📄 denoiseSpeechBatch.m
```


## Scripts

# calculateAudioError.m
Calculated best performance metrics from between the clean and denoised audio signals:
RMSE
MSE
SNR (dB)
PSNR (dB)
MAE
NRMSE
Correlation coefficient

# calculateCorrelationBatch.m
Processed a batch of denoised signals and compared them to the clean signals by use of correlation. 
To do this, it:
Looped through 10 clean files and 10 denoised variations
Used calculateAudioError for metric computation
Outputed a correlation matrix and average correlation

# denoiseSpeechBatch.m
Included two key functions:
denoiseSpeechFile: Processed one file through STFT, network inference, and ISTFT
denoiseSpeechDir: Processed all .wav files in a directory
Outputs denoised .wav files to a specific directory.

## Evaluation Example
denoisedAudioArray = denoiseSpeechDir("data/test/simpleTest/noisyInput", "data/test/simpleTest/testOutput");

[correlations, avgCorr] = calculateCorrelationBatch(denoisedAudioArray, "data/test/simpleTest/clean");

disp(['Average Correlation: ', num2str(avgCorr)]);

## Dependencies
MATLAB R2023a or later
Audio Toolbox
Deep Learning Toolbox
Signal Processing Toolbox

## Sample Output
Denoised files are saved with _dn.wav suffix in the testOutput directory. They are able to be audibly listened to for comparison to their quality  against the clean originals.

## License
This project was just for academic and non-commercial use only. We do not know if there is a License File or not, this project was in pursuit of the Mathworks A.I. challenge
