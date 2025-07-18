## Speech Noise Suppression with Deep Learning in MATLAB

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=eric-vo/mathworks-noise-suppression&file=scripts/main.m)

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
Denoised files are saved with _dn.wav suffix in the testOutput directory. They are able to be audibly listened to for comparison to their quality against the clean originals.

### Subjective Evaluation of Denoised Files
We evaluated the clarity of denoised files (in relation to their corresponding noisy files) on a scale from 1 to 5: 1 representing the worst clarity, and 5 representing the best possible clarity. Here are evaluations of some test files:

10_waves_10dB_dn.wav: 3.5
10_pencils_10dB_dn.wav: 3.2
10_jet_city_birds_5db_dn.wav: 3.0
10_cafe_5db_dn.wav: 2.8
10_birds_farm_5db_dn.wav: 3.2


## License

This project was just for academic and non-commercial use only. 

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
