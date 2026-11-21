%% Lab 9: Image Preprocessing and Segmentation without AI
% tire_stud_detector.m - detects metal studs on tires
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% Needs the Image Processing Toolbox.
clear; clc; close all;

imageFiles = {'studded_tire.jpg', 'summer_tire.jpg'};

% Settings (chosen for these two images after resizing by 0.5)
BG_THRESHOLD     = 200;   % background is white, tire is darker than this
BRIGHT_THRESHOLD = 190;   % a stud is a bright metal point
CONTRAST_MIN     = 90;    % ... that is much brighter than its surroundings
MIN_STUDS        = 15;    % decision rule: more than this many studs = studded

for i = 1:numel(imageFiles)

    % ---------- 1) Read & resize ----------
    I = imread(imageFiles{i});
    I = imresize(I, 0.5);   % optional scaling

    % ---------- 2) Convert to grayscale ----------
    if size(I, 3) == 3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    % ---------- 3) Create tire mask ----------
    % The tire is darker than the white background
    tireMask = Igray < BG_THRESHOLD;
    tireMask = imfill(tireMask, 'holes');      % fill bright parts inside the tire
    tireMask = bwareafilt(tireMask, 1);        % keep only the largest object
    tireArea = nnz(tireMask);
    % Shrink the mask a little, so the bright edge between tire and
    % background is not taken as a stud
    tireInner = imerode(tireMask, strel('disk', 6));

    % ---------- 4) Candidate studs ----------
    % Studs are bright points INSIDE the tire.
    % The top-hat transform removes everything that is larger than a small
    % disk, so only small bright details on a darker surrounding are left.
    localContrast = imtophat(Igray, strel('disk', 4, 0));
    cand = (Igray > BRIGHT_THRESHOLD) & (localContrast > CONTRAST_MIN) & tireInner;
    cand = bwareaopen(cand, 4);                % remove single-pixel noise
    cand = imfill(cand, 'holes');

    % ---------- 5) Connected components ----------
    CC = bwconncomp(cand);
    stats = regionprops(CC, 'Area', 'Perimeter', 'Eccentricity');

    % ---------- 6) Filter candidates ----------
    studMask = false(size(cand));
    studCount = 0;

    % Limits for a stud in these images:
    minA = 4;       % min area of a stud
    maxA = 120;     % max area of a stud
    minCirc = 0.6;  % minimum circularity
    maxEcc = 0.85;  % maximum eccentricity

    for k = 1:numel(stats)
        A = stats(k).Area;
        P = stats(k).Perimeter;
        if P > 0
            circ = 4*pi*A / P^2;   % 1 for a circle, smaller for long shapes
        else
            circ = 1;              % very small blob
        end
        if A >= minA && A <= maxA && circ >= minCirc && stats(k).Eccentricity <= maxEcc
            studMask(CC.PixelIdxList{k}) = true;
            studCount = studCount + 1;
        end
    end

    % ---------- 7) Decision rule ----------
    density = 1e4 * studCount / tireArea;      % studs per 10 000 tire pixels
    isStudded = (studCount > MIN_STUDS);

    if isStudded
        label = 'STUDDED TIRE';
    else
        label = 'NON-STUDDED TIRE';
    end
    fprintf('%s: size %d x %d, tire area %d px, candidates %d, studs %d, density %.2f per 10^4 px -> %s\n', ...
        imageFiles{i}, size(Igray,1), size(Igray,2), tireArea, CC.NumObjects, studCount, density, label);

    % ---------- 8) Visualization ----------
    figure;
    subplot(1,3,1);
    imshow(I); title(sprintf('Input: %s', imageFiles{i}), 'Interpreter','none');

    subplot(1,3,2);
    imshow(cand); title('Candidate studs (binary)');

    subplot(1,3,3);
    imshow(I); hold on;
    visboundaries(studMask, 'LineWidth', 0.7);

    if isStudded
        title(sprintf('STUDDED TIRE (studs: %d)', studCount));
    else
        title(sprintf('NON-STUDDED TIRE (studs: %d)', studCount));
    end

    % Extra figure: the tire mask (added)
    figure;
    subplot(1,2,1); imshow(Igray); title('Grayscale');
    subplot(1,2,2); imshow(tireMask); title('Tire mask');

end

%% Save all figures as PNG files for the GitHub report (added)
figs = findobj('Type','figure');
for k = 1:numel(figs)
    exportgraphics(figs(k), sprintf('figure_%02d.png', figs(k).Number), 'Resolution', 150);
end
