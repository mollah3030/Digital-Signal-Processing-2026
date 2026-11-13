%% Z-Transform and Delays
% Md Mohiuddin Mollah - Digital Signal Processing 2026
clear; clc; close all;

%% Part 1: the signal x[n] and its one-sample delay
x = [1 2 1];
n = 0:length(x)-1;

% Delay the signal by one sample
xDelayed = [0 x];
nDelayed = 0:length(xDelayed)-1;

figure;
subplot(2,1,1);
stem(n, x, 'filled');
title('Original Signal x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

subplot(2,1,2);
stem(nDelayed, xDelayed, 'filled');
title('One-Sample Delay x[n-1]');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

saveas(gcf, 'original_and_delayed.png');

%% Part 2: system H(z) = 0.5 + 0.5z^(-1)
b = [0.5 0.5];
a = 1;

% Add one zero to show the final output sample
xInput = [x 0];
y = filter(b, a, xInput);
nOutput = 0:length(y)-1;

figure;
subplot(2,1,1);
stem(nOutput, xInput, 'filled');
title('Input x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

subplot(2,1,2);
stem(nOutput, y, 'filled');
title('Output y[n] for H(z) = 0.5 + 0.5z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

saveas(gcf, 'averaging_output.png');

disp('Output samples for b = [0.5 0.5]:');
disp(y);

%% Task 6: changed system H(z) = 0.8 + 0.2z^(-1)
b2 = [0.8 0.2];
y2 = filter(b2, a, xInput);

figure;
subplot(2,1,1);
stem(nOutput, xInput, 'filled');
title('Input x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

subplot(2,1,2);
stem(nOutput, y2, 'filled');
title('Output y[n] for H(z) = 0.8 + 0.2z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
grid on; xlim([-0.5 3.5]); ylim([0 2.5]);

saveas(gcf, 'modified_output.png');

disp('Output samples for b = [0.8 0.2]:');
disp(y2);
