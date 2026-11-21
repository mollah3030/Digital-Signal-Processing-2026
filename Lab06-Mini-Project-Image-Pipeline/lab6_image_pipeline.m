%% Lab 6: Mini Project - Your Image Pipeline
% Md Mohiuddin Mollah - Digital Signal Processing 2026
%
% Problem: get a clean outline of the object in a photo that is corrupted
% by salt & pepper noise.
% Image: football.jpg, a MATLAB sample image (Image Processing Toolbox).
% The noise is added in the script, so the clean image is known and the
% result of each stage can be measured.
close all; clear; clc;
rng(1);   % fixed seed, so the numbers in the README can be reproduced

% 1) Load the image (object, face, landscape, etc.)
I_clean = im2double(rgb2gray(imread('football.jpg')));
I = imnoise(I_clean, 'salt & pepper', 0.03);     % simulated sensor noise (3 % of the pixels)
fprintf('Image size: %d x %d, grey range of the clean image: [%.2f, %.2f]\n', size(I,1), size(I,2), min(I_clean(:)), max(I_clean(:)));

% 2) Pre-process: noise removal
I_filt = medfilt2(I,[3 3]);

% 3) Enhance contrast
I_enh = imadjust(I_filt,[0.2 0.8],[0 1]);

% 4) Extract features (edges or frequency)
edges = edge(I_enh,'Canny',[0.1 0.25]);

% 5) Optional frequency-domain mask
F = fftshift(fft2(I_enh));
[M,N]=size(F);
[u,v]=meshgrid(-N/2:N/2-1,-M/2:M/2-1);
H = double(sqrt(u.^2+v.^2)<60);
I_lp = real(ifft2(ifftshift(F.*H)));

% 6) Visualization
figure; montage({I, I_filt, I_enh, edges, I_lp},'Size',[1 5]);
title('Original | Denoised | Enhanced | Edges | LP result');

%% Measurements for the report (added)
% Stage 2: how much noise does the median filter remove?
fprintf('PSNR against the clean image: noisy %.2f dB | after median %.2f dB\n', psnr(I, I_clean), psnr(I_filt, I_clean));
fprintf('Noise pixels (exactly 0 or 1): before %d | after median %d\n', nnz(I==0 | I==1), nnz((I_filt==0 | I_filt==1) & ~(I_clean==0 | I_clean==1)));

% Stage 3: contrast before and after
fprintf('Grey range used (1st to 99th percentile): before [%.2f, %.2f] | after [%.2f, %.2f]\n', prctile(I_filt(:),1), prctile(I_filt(:),99), prctile(I_enh(:),1), prctile(I_enh(:),99));
fprintf('Standard deviation of the grey values: before %.3f | after %.3f\n', std(I_filt(:)), std(I_enh(:)));

% Stage 4: edges with and without the earlier stages
edges_raw     = edge(I,      'Canny', [0.1 0.25]);   % straight on the noisy image
edges_denoise = edge(I_filt, 'Canny', [0.1 0.25]);   % after the median filter only
edges_ref     = edge(imadjust(I_clean,[0.2 0.8],[0 1]), 'Canny', [0.1 0.25]);   % same steps on the clean image
tol = imdilate(edges_ref, strel('disk', 1));          % allow a shift of one pixel
fprintf('Canny edge pixels: noisy image %d | median only %d | full pipeline %d | clean reference %d\n', nnz(edges_raw), nnz(edges_denoise), nnz(edges), nnz(edges_ref));
fprintf('Edge pixels that agree with the clean reference: noisy image %.1f %% | full pipeline %.1f %%\n', 100*nnz(edges_raw & tol)/nnz(edges_raw), 100*nnz(edges & tol)/nnz(edges));

% Stage 5: what the ideal low-pass mask keeps
fprintf('Low-pass mask: radius 60, keeps %.1f %% of the frequency samples and %.2f %% of the energy\n', 100*mean(H(:)), 100*sum(abs(F(:).*H(:)).^2)/sum(abs(F(:)).^2));
fprintf('LP result range: [%.3f, %.3f]\n', min(I_lp(:)), max(I_lp(:)));

% Extra figures (added)
figure; montage({I_clean, I, edges_raw, edges},'Size',[1 4]);
title('Clean image | Noisy input | Edges without pre-processing | Edges after the pipeline');

figure;
subplot(1,2,1); imhist(I_filt); title('Histogram after denoising');
subplot(1,2,2); imhist(I_enh);  title('Histogram after contrast stretch');

figure;
subplot(1,2,1); imshow(log(1+abs(F)),[]); title('Spectrum of the enhanced image');
subplot(1,2,2); imshow(H,[]); title('Low-pass mask (radius 60)');

%% 7) Report: see README.md

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
