%% Lab 3: Frequency-Domain Filtering with fft2
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% -------------------------------------------------------------------------
% - Ideal LP causes ringing (Gibbs) due to hard cutoff.
% - Convolution theorem: spatial convolution <-> frequency multiplication.
% - Compare spatial vs frequency-domain Gaussian LP (should match closely).
% -------------------------------------------------------------------------
close all; clear; clc;
if exist('peppers.png','file')
    I0 = imread('peppers.png');
else
    I0 = repmat(imread('cameraman.tif'),1,1,3);
end
I = im2double(rgb2gray(I0));
[M,N] = size(I);

%% 1) Magnitude spectrum (log-scale)
F = fft2(I);
Fshift = fftshift(F);
S = log(1 + abs(Fshift));
figure;
subplot(1,2,1); imshow(I,[]); title('Image');
subplot(1,2,2); imshow(S,[]); title('Log-magnitude spectrum (centered)');

%% 2) Ideal & Gaussian Low-pass in frequency
[u,v] = meshgrid( (-floor(N/2)) : (ceil(N/2)-1), (-floor(M/2)) : (ceil(M/2)-1) );
D = sqrt(u.^2 + v.^2);
D0 = 40; % cutoff radius
H_ideal_LP = double(D <= D0); % ideal circular LP
sigma = 20;
H_gauss_LP = exp(-(D.^2) / (2*sigma^2));

% Show the two filter masks (added)
figure;
subplot(1,2,1); imshow(H_ideal_LP,[]); title('Ideal low-pass mask (D0 = 40)');
subplot(1,2,2); imshow(H_gauss_LP,[]); title('Gaussian low-pass mask (sigma = 20)');

%% 3) Apply LP filters in frequency domain
G_ideal = ifft2( ifftshift( H_ideal_LP .* Fshift ) );
G_gauss = ifft2( ifftshift( H_gauss_LP .* Fshift ) );
figure; montage({I, real(G_ideal), real(G_gauss)}, 'Size', [1 3]);
title('Original | Ideal LP | Gaussian LP (ringing vs smooth)');

% Ringing shows up as values outside the original range [0,1] (added)
fprintf('Image size: %d x %d\n', M, N);
fprintf('Ideal LP output range:    [%.4f, %.4f]\n', min(real(G_ideal(:))), max(real(G_ideal(:))));
fprintf('Gaussian LP output range: [%.4f, %.4f]\n', min(real(G_gauss(:))), max(real(G_gauss(:))));
fprintf('Share of spectrum energy kept: ideal %.2f %% | Gaussian %.2f %%\n', ...
    100*sum(abs(H_ideal_LP(:).*Fshift(:)).^2)/sum(abs(Fshift(:)).^2), ...
    100*sum(abs(H_gauss_LP(:).*Fshift(:)).^2)/sum(abs(Fshift(:)).^2));

%% 4) High-pass via complement
H_gauss_HP = 1 - H_gauss_LP;
G_hp = real( ifft2( ifftshift( H_gauss_HP .* Fshift ) ) );
G_hp = mat2gray(G_hp);
figure; montage({I, G_hp}, 'Size', [1 2]);
title('Original | Gaussian High-pass result');

%% 5) Compare spatial vs frequency-domain Gaussian LP
g1d = fspecial('gaussian',[1 7], 1.2);
I_spatial_gauss = imfilter(I, g1d'*g1d, 'replicate');
figure; montage({I_spatial_gauss, real(G_gauss)}, 'Size', [1 2]);
title('Spatial Gaussian LP | Frequency-domain Gaussian LP');

% Numerical comparison of the two results (added)
dd = abs(I_spatial_gauss - real(G_gauss));
fprintf('Spatial vs frequency Gaussian LP: mean abs difference %.4f, max %.4f\n', mean(dd(:)), max(dd(:)));
% A frequency Gaussian with sigma_f corresponds to a spatial Gaussian with
% sigma_x = N/(2*pi*sigma_f) (horizontal) and M/(2*pi*sigma_f) (vertical)
fprintf('Equivalent spatial sigma of the frequency filter: %.2f px (horizontal), %.2f px (vertical)\n', N/(2*pi*sigma), M/(2*pi*sigma));

%% 6) Reflections: see README.md

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
