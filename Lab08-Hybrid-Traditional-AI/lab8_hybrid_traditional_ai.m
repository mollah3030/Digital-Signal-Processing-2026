%% Lab 8: Hybrid Project - Traditional + AI Pipeline
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% Needs the Image Processing Toolbox, the Deep Learning Toolbox and the
% Deep Learning Toolbox Model for SqueezeNet Network.
close all; clear; clc;
rng(1);   % added: k-means starts from random centres, so fix the seed

% ---------------------------------------------------
% Section 1: Load Image and AI Network
% ---------------------------------------------------
% Load a sample image
% We will try to classify the isolated object using AI
targetImage = imread('peppers.png'); % Using a common sample image
% Load a pre-trained SqueezeNet network for classification (a small, fast CNN)
disp('Loading pre-trained AI network (SqueezeNet)...');
net = squeezenet;
disp('Network loaded.');
figure('Name', 'Hybrid Pipeline Images');
subplot(2, 2, 1); imshow(targetImage); title('Original Image');

% ---------------------------------------------------
% Section 2: Traditional Method (Color Segmentation using K-Means)
% Role: Isolate the main object of interest using a traditional algorithm.
% ---------------------------------------------------
disp('Applying traditional color segmentation (K-Means)...');
% Reshape image for k-means clustering based on color
imgLab = rgb2lab(targetImage);
ab = imgLab(:,:,2:3);
ab = im2single(ab);
pixelLabels = imsegkmeans(ab, 2); % Cluster into 2 colors
% Create a mask to isolate the main object (assuming the object is Cluster 2)
mask = pixelLabels == 2;
% Apply the mask to the original image to get the isolated object area
isolatedObject = targetImage;
isolatedObject(repmat(~mask, 1, 1, 3)) = 0; % Set background pixels to black
subplot(2, 2, 2); imshow(mask); title('Traditional Mask (K-Means)');
subplot(2, 2, 3); imshow(isolatedObject); title('Isolated Object (Input to AI)');

% Size and mean colour of the two clusters (added)
for k = 1:2
    m = pixelLabels == k;
    px = reshape(targetImage, [], 3);
    fprintf('Cluster %d: %.1f %% of the pixels, mean RGB = [%.0f %.0f %.0f]\n', k, 100*mean(m(:)), mean(px(m(:),:), 1));
end

% ---------------------------------------------------
% Section 3: AI Method (Image Classification)
% Role: Use deep learning to classify the isolated object.
% ---------------------------------------------------
disp('Running AI classification on the isolated object...');
% The AI network requires a specific input size (SqueezeNet needs 227x227x3)
inputSize = net.Layers(1).InputSize;
resizedObject = imresize(isolatedObject, [inputSize(1) inputSize(2)]);
% Classify the image using the pre-trained network
[YPred, probs] = classify(net, resizedObject);

% ---------------------------------------------------
% Section 4: Results Analysis
% ---------------------------------------------------
subplot(2, 2, 4); imshow(resizedObject); title('Resized Input to AI');
fprintf('\n--- Hybrid Pipeline Results ---\n');
fprintf('The AI model classified the isolated object as: **%s**\n', string(YPred));
fprintf('Confidence (Probability): %.2f%%\n', max(probs)*100);

% ---------------------------------------------------
% Section 5 (added): compare with the AI alone and with the other cluster
% ---------------------------------------------------
classNames = net.Layers(end).Classes;
fprintf('Network input size: %d x %d x %d, number of classes: %d\n', inputSize(1), inputSize(2), inputSize(3), numel(classNames));

otherObject = targetImage;
otherObject(repmat(mask, 1, 1, 3)) = 0;       % keep cluster 1 instead

inputs = {imresize(targetImage, inputSize(1:2)), resizedObject, imresize(otherObject, inputSize(1:2))};
labels = {'AI only (original image)', 'Hybrid (cluster 2 isolated)', 'Hybrid (cluster 1 isolated)'};
figure('Name', 'Inputs compared');
for k = 1:3
    [~, p] = classify(net, inputs{k});
    [ps, idx] = maxk(p, 3);
    fprintf('\n%s - top 3:\n', labels{k});
    for j = 1:3
        fprintf('  %-22s %6.2f %%\n', string(classNames(idx(j))), 100*ps(j));
    end
    subplot(1, 3, k); imshow(inputs{k});
    title(sprintf('%s\n%s (%.1f %%)', labels{k}, string(classNames(idx(1))), 100*ps(1)), 'FontSize', 8);
end

% The idea is that isolating the *object* first (traditional) helps the
% *classifier* (AI) focus purely on the target. See README.md for what
% actually happened with this image.

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
