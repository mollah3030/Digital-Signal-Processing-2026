%% Lab 2: 2D Convolution & FIR Filters (Blur, Sharpen, Edges)
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% - Kernel = impulse response h[m,n].
% - Prefer Gaussian over large box for smoother frequency response.
% - Discuss separability (two 1D passes) and boundary handling.
% -------------------------------------------------------------------------
close all; clear; clc;
if exist('peppers.png','file')
    I0 = imread('peppers.png');
else
    I0 = repmat(imread('cameraman.tif'),1,1,3);
end
I = im2double(rgb2gray(I0));

%% 1) Delta image & impulse response
delta = zeros(101,101); delta(51,51) = 1;
h_avg = ones(3,3)/9;
H_vis = conv2(delta, h_avg, 'same');
figure; imagesc(H_vis); axis image off; colorbar; title('Impulse response of 3x3 average');

fprintf('Impulse response: %d non-zero pixels, each %.4f, sum %.4f\n', nnz(H_vis), max(H_vis(:)), sum(H_vis(:)));

%% 2) Low-pass: box vs Gaussian, separability
h_box3 = ones(3,3)/9;
h_box7 = ones(7,7)/49;
sigma = 1.2;
g1d = fspecial('gaussian',[1 7], sigma);
h_gauss = g1d'*g1d; % separable
I_box3 = imfilter(I, h_box3, 'replicate');
I_box7 = imfilter(I, h_box7, 'replicate');
I_gauss = imfilter(I, h_gauss, 'replicate');
figure; montage({I, I_box3, I_box7, I_gauss},'Size',[1 4]);
title('Original | Box 3x3 | Box 7x7 | Gaussian (separable)');

% Separability check: two 1D passes against one 2D pass (added)
I_sep = imfilter(imfilter(I, g1d, 'replicate'), g1d', 'replicate');
fprintf('Max difference, 2D Gaussian vs two 1D passes: %g\n', max(abs(I_sep(:) - I_gauss(:))));
fprintf('Multiplications per pixel: 2D 7x7 = %d, separable = %d\n', 7*7, 7+7);

%% 3) Unsharp masking (sharpen)
I_blur = imfilter(I, h_gauss, 'replicate');
mask = I - I_blur; % high-frequency
gain = 1.0;
I_sharp = max(min(I + gain*mask,1),0);
figure; montage({I, I_blur, mask, I_sharp},'Size',[1 4]);
title('Original | Blur | High-freq mask | Sharpened');

%% 4) Edges: Sobel & Laplacian
h_sobel_x = fspecial('sobel');
h_sobel_y = h_sobel_x';
Gx = imfilter(I, h_sobel_x, 'replicate');
Gy = imfilter(I, h_sobel_y, 'replicate');
Gmag = hypot(Gx, Gy);
h_lap = fspecial('laplacian', 0.2);
I_lap = imfilter(I, h_lap, 'replicate');
figure; montage({mat2gray(Gx), mat2gray(Gy), mat2gray(Gmag), mat2gray(I_lap)},'Size',[1 4]);
title('Sobel Gx | Sobel Gy | Gradient magnitude | Laplacian');

%% 5) Correlation vs convolution (kernel flip)
C1 = conv2(I, h_box3, 'same');
C2 = imfilter(I, h_box3, 'conv', 'same'); % 'conv' flips internally
diff_val = max(abs(C1(:)-C2(:)));
fprintf('Max difference (conv2 vs imfilter with conv): %g\n', diff_val);

%% 6) Boundary handling
I_rep = imfilter(I, h_box7, 'replicate');
I_sym = imfilter(I, h_box7, 'symmetric');
I_cir = imfilter(I, h_box7, 'circular');
figure; montage({I_rep, I_sym, I_cir},'Size',[1 3]);
title('Boundary: replicate | symmetric | circular');

% How much the three modes differ, and where (added)
d_rs = abs(I_rep - I_sym); d_rc = abs(I_rep - I_cir);
fprintf('Max difference replicate vs symmetric: %.4f | replicate vs circular: %.4f\n', max(d_rs(:)), max(d_rc(:)));
inner = false(size(I)); inner(4:end-3, 4:end-3) = true;
fprintf('Max difference in the interior (more than 3 pixels from the border): %g\n', max(d_rc(inner)));

%% 7) Reflections: see README.md

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
