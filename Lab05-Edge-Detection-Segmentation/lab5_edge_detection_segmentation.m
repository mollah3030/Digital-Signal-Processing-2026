%% Lab 5: Edge Detection and Segmentation
% Md Mohiuddin Mollah - Digital Signal Processing 2026
close all; clear; clc;
I = im2double(rgb2gray(imread('peppers.png')));

%% 1) Basic derivative filters (Sobel, Prewitt)
edges_sobel = edge(I,'Sobel');
edges_prewitt = edge(I,'Prewitt');
figure; montage({edges_sobel, edges_prewitt},'Size',[1 2]);
title('Sobel | Prewitt edges');

%% 2) Canny detector (multi-stage)
edges_canny = edge(I,'Canny',[0.05 0.2]);
figure; imshow(edges_canny); title('Canny edges');

%% 3) Laplacian of Gaussian (LoG)
edges_log = edge(I,'log');
figure; imshow(edges_log); title('Laplacian of Gaussian edges');

% Number of edge pixels found by each operator (added)
fprintf('Edge pixels: Sobel %d | Prewitt %d | Canny %d | LoG %d\n', nnz(edges_sobel), nnz(edges_prewitt), nnz(edges_canny), nnz(edges_log));
fprintf('Pixels where Sobel and Prewitt agree: %.1f %% of the Sobel edges\n', 100*nnz(edges_sobel & edges_prewitt)/nnz(edges_sobel));

%% 4) Edge map -> segmentation (Otsu threshold)
level = graythresh(I); % Otsu method
BW = imbinarize(I,level);
figure; montage({I,BW},'Size',[1 2]);
title('Original | Otsu threshold binary mask');

fprintf('Otsu threshold: %.4f (grey value %d of 255), %.1f %% of the pixels are foreground\n', level, round(255*level), 100*mean(BW(:)));

% Histogram with the Otsu threshold marked (added)
figure; imhist(I); hold on; xline(level, 'r', 'LineWidth', 2);
title(sprintf('Histogram with Otsu threshold at %.3f', level));

%% 5) Label and visualize regions
[L,num] = bwlabel(BW);
RGB = label2rgb(L);
figure; imshow(RGB); title(['Labeled regions: ',num2str(num)]);

% Size of the labelled regions (added)
stats = regionprops(L, 'Area');
areas = sort([stats.Area], 'descend');
fprintf('Labeled regions: %d | largest %d px | regions smaller than 50 px: %d\n', num, areas(1), nnz(areas < 50));

%% 6) Reflections: see README.md

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
