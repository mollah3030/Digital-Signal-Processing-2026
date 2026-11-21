%% Lab 7: Traditional vs AI Gaussian Filters
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% Needs the Image Processing Toolbox and the Deep Learning Toolbox.
close all; clear; clc;
rng(1);   % added: fixed seed, so the numbers in the README can be reproduced

% --- 1. Setup: Load an image and add Gaussian noise ---
% Read a sample image and convert to grayscale double format
originalImage = im2double(imread('cameraman.tif'));
% Define the noise standard deviation
noiseSigma = 0.04;
% Add Gaussian noise to the image
noisyImage = imnoise(originalImage, 'gaussian', 0, noiseSigma^2);
% Display the original and noisy images
figure('Name', 'Gaussian Noise Denoising Comparison');
subplot(1, 4, 1); imshow(originalImage); title('Original Image');
subplot(1, 4, 2); imshow(noisyImage); title('Noisy Image');

% --- 2. Traditional Filter (Adaptive Wiener Filter) ---
% The Wiener filter is a traditional adaptive filter that performs well
% with additive white Gaussian noise. It adapts its smoothing level based
% on local variance, preserving edges better than a simple Gaussian blur.
% We provide the estimated noise variance for better results.
traditionalFiltered = wiener2(noisyImage, [5 5], noiseSigma^2);
% Display the result of the traditional filter
subplot(1, 4, 3); imshow(traditionalFiltered); title('Traditional (Wiener) Filter');

% --- 3. AI Filter (Pre-trained DnCNN) ---
% The pre-trained DnCNN network in MATLAB is specifically designed
% for grayscale images with Gaussian noise within a certain range.
% It automatically learns complex features to remove noise while
% preserving details.
% Load the pre-trained denoising CNN model
net = denoisingNetwork('DnCNN');
% Apply the deep learning filter
tic;
aiFiltered = denoiseImage(noisyImage, net);
tAI = toc;
% Display the result of the AI filter
subplot(1, 4, 4); imshow(aiFiltered); title('AI (DnCNN) Filter');

% --- 4. Quantitative Evaluation (PSNR and SSIM) ---
% Calculate PSNR (Peak Signal-to-Noise Ratio) and SSIM (Structural Similarity Index)
% Higher values indicate better quality.
psnrNoisy = psnr(noisyImage, originalImage);
ssimNoisy = ssim(noisyImage, originalImage);
psnrTraditional = psnr(traditionalFiltered, originalImage);
ssimTraditional = ssim(traditionalFiltered, originalImage);
psnrAI = psnr(aiFiltered, originalImage);
ssimAI = ssim(aiFiltered, originalImage);
% Display the metrics
fprintf('\n--- Image Quality Metrics Comparison ---\n');
fprintf('Method                | PSNR (dB) | SSIM\n');
fprintf('----------------------|-----------|----------\n');
fprintf('Noisy Image           | %8.4f  | %8.4f\n', psnrNoisy, ssimNoisy);
fprintf('Traditional (Wiener)  | %8.4f  | %8.4f\n', psnrTraditional, ssimTraditional);
fprintf('AI (DnCNN)            | %8.4f  | %8.4f\n', psnrAI, ssimAI);

% --- 4b. Other traditional filters and MSE (added) ---
meanFiltered   = imfilter(noisyImage, fspecial('average', 3), 'replicate');
medianFiltered = medfilt2(noisyImage, [3 3]);
gaussFiltered  = imgaussfilt(noisyImage, 1);
names = {'Noisy image', 'Mean 3x3', 'Median 3x3', 'Gaussian blur (sigma 1)', 'Wiener 5x5', 'DnCNN'};
imgs  = {noisyImage, meanFiltered, medianFiltered, gaussFiltered, traditionalFiltered, aiFiltered};
fprintf('\n%-26s %9s %10s %8s\n', 'Method', 'MSE', 'PSNR (dB)', 'SSIM');
for k = 1:numel(imgs)
    fprintf('%-26s %9.5f %10.2f %8.4f\n', names{k}, immse(imgs{k}, originalImage), psnr(imgs{k}, originalImage), ssim(imgs{k}, originalImage));
end
tic; wiener2(noisyImage, [5 5], noiseSigma^2); tW = toc;
fprintf('\nRun time: Wiener %.3f s | DnCNN %.3f s\n', tW, tAI);
fprintf('DnCNN network: %d layers\n', numel(net.Layers));

% Zoomed region for a visual comparison of detail (added)
r = 30:129; c = 80:179;
figure('Name', 'Zoomed comparison');
montage({originalImage(r,c), noisyImage(r,c), traditionalFiltered(r,c), aiFiltered(r,c)}, 'Size', [1 4]);
title('Zoom: Original | Noisy | Wiener | DnCNN');

% --- 5. Visual Observation: see README.md ---

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
