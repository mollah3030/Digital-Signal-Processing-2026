%% Lecture 01 - Signal Visualization
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% Creates sine waves, compares frequency and amplitude, adds noise
% and saves the required figures as PNG files.

clear;
close all;
clc;

%% Common time axis
duration = 1;                 % signal length in seconds
dt = 0.001;                   % time step (1 ms)
t = 0:dt:duration;            % time vector

%% Task 1: Create a sine wave (A = 1, f = 5 Hz, 1 second)
A = 1;                        % amplitude
f = 5;                        % frequency in Hz
x = A * sin(2*pi*f*t);

figure;
plot(t, x);
title('5 Hz Sine Wave');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

%% Task 2: Compare different frequencies (2, 5 and 10 Hz)
freqs = [2 5 10];

figure;
for k = 1:length(freqs)
    subplot(3,1,k);
    plot(t, sin(2*pi*freqs(k)*t));
    title([num2str(freqs(k)), ' Hz Sine Wave']);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;
end
sgtitle('Frequency Comparison');

saveas(gcf, 'frequency_comparison.png');

%% Task 3: Compare different amplitudes (0.5, 1 and 2) at 5 Hz
amps = [0.5 1 2];
fAmp = 5;                     % same frequency for all three signals

figure;
for k = 1:length(amps)
    subplot(3,1,k);
    plot(t, amps(k) * sin(2*pi*fAmp*t));
    title(['Amplitude = ', num2str(amps(k))]);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;
end
sgtitle('Amplitude Comparison');

saveas(gcf, 'amplitude_comparison.png');

%% Task 4: Add noise to a clean sine wave
cleanSignal = sin(2*pi*5*t);
noiseLevel = 0.3;                              % standard deviation of the noise
noisySignal = cleanSignal + noiseLevel*randn(size(t));

figure;
subplot(2,1,1);
plot(t, cleanSignal);
title('Clean 5 Hz Sine Wave');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, noisySignal);
title('Noisy 5 Hz Sine Wave');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

sgtitle('Clean vs Noisy Signal');

%% Task 5: Save the last figure
saveas(gcf, 'clean_vs_noisy_signal.png');
