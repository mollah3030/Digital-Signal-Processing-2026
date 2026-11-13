%% Lecture 02 - Sampling and Aliasing
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% A 10 Hz sine wave is sampled at five sampling frequencies to show
% when the samples describe the signal correctly and when aliasing occurs.

clear;
close all;
clc;

%% Signal parameters
f0 = 10;                 % signal frequency (Hz)
Tend = 1;                % duration (s)

% Very small time step, so the curve behaves like a continuous-time signal
dt = 0.0001;
t = 0:dt:Tend;
x = sin(2*pi*f0*t);

%% Task 1 - Original signal
figure;
plot(t, x, 'LineWidth', 1.5);
title('Original 10 Hz Sine Wave');
xlabel('Time (s)');
ylabel('Amplitude');
legend('10 Hz sine wave');
grid on;

saveas(gcf, 'original_signal.png');

%% Task 2 - Sample the signal at different sampling frequencies
fsList = [15 20 25 50 100];        % sampling frequencies (Hz)

for k = 1:length(fsList)

    fs = fsList(k);
    Ts = 1/fs;                     % sampling period (s)
    ts = 0:Ts:Tend;                % sampling instants
    xs = sin(2*pi*f0*ts);          % sampled values

    fprintf('fs = %3d Hz, Ts = %.4f s, samples per cycle = %.1f\n', ...
        fs, Ts, fs/f0);

    figure;
    plot(t, x, 'LineWidth', 1.5);
    hold on;
    stem(ts, xs, 'filled');
    hold off;

    title(['10 Hz Signal Sampled at ', num2str(fs), ' Hz']);
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend('Original signal', 'Samples');
    grid on;

    saveas(gcf, ['sampling_', num2str(fs), 'Hz.png']);

end

%% Task 3 - Nyquist rate
fNyquistRate = 2*f0;
fprintf('Nyquist rate = 2 * %d Hz = %d Hz\n', f0, fNyquistRate);
