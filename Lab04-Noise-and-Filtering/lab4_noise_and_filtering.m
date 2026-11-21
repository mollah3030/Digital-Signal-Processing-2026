%% Lab 4: Noise and Filtering
% Md Mohiuddin Mollah - Digital Signal Processing 2026
close all; clear; clc;
rng(1);   % added: fixed seed, so the numbers in the README can be reproduced
I = im2double(rgb2gray(imread('peppers.png')));

%% 1) Add different noise types
I_gauss = imnoise(I,'gaussian',0,0.01);
I_sp = imnoise(I,'salt & pepper',0.05);
figure; montage({I, I_gauss, I_sp},'Size',[1 3]);
title('Original | Gaussian noise | Salt & pepper noise');

%% 2) Compute simple quality metrics
MSE_gauss = immse(I_gauss, I);
MSE_sp = immse(I_sp, I);
fprintf('MSE Gaussian: %.4f | MSE S&P: %.4f\n', MSE_gauss, MSE_sp);

% SNR in dB = 10*log10(signal power / noise power) (added)
snr_db = @(X) 10*log10(mean(I(:).^2) / immse(X, I));
fprintf('SNR Gaussian: %.2f dB | SNR S&P: %.2f dB\n', snr_db(I_gauss), snr_db(I_sp));

%% 3) Linear filtering (mean, Gaussian)
h_avg = fspecial('average',3);
I_avg_gauss = imfilter(I_gauss,h_avg,'replicate');
I_avg_sp = imfilter(I_sp,h_avg,'replicate');
h_gauss = fspecial('gaussian',[3 3],0.7);
I_gauss_gauss = imfilter(I_gauss,h_gauss,'replicate');

%% 4) Non-linear filtering (median)
I_med_gauss = medfilt2(I_gauss,[3 3]);
I_med_sp = medfilt2(I_sp,[3 3]);
figure; montage({I_avg_sp, I_med_sp, I_avg_gauss, I_med_gauss},'Size',[2 2]);
title('Top: Avg vs Median (S&P) | Bottom: Avg vs Median (Gaussian)');

%% 5) Compare metrics after filtering
fprintf('After filtering, MSE S&P avg=%.4f, med=%.4f\n',...
    immse(I_avg_sp,I), immse(I_med_sp,I));

% Full table of MSE and SNR for every result (added)
names = {'Gaussian noise, no filter', 'Gaussian noise, mean 3x3', 'Gaussian noise, Gaussian 3x3', 'Gaussian noise, median 3x3', ...
         'S&P noise, no filter', 'S&P noise, mean 3x3', 'S&P noise, median 3x3'};
imgs = {I_gauss, I_avg_gauss, I_gauss_gauss, I_med_gauss, I_sp, I_avg_sp, I_med_sp};
fprintf('\n%-30s %8s %9s\n', 'Image', 'MSE', 'SNR (dB)');
for k = 1:numel(imgs)
    fprintf('%-30s %8.4f %9.2f\n', names{k}, immse(imgs{k}, I), snr_db(imgs{k}));
end

% Zoomed region to compare edge blur (added)
r = 150:249; c = 200:299;
figure; montage({I(r,c), I_sp(r,c), I_avg_sp(r,c), I_med_sp(r,c)},'Size',[1 4]);
title('Zoom: Original | S&P noise | Mean 3x3 | Median 3x3');

%% 6) Reflections: see README.md

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
