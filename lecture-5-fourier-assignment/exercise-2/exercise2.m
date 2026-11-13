%% Exercise 2 - Find two frequencies with the FFT
clear; clc; close all;

fs = 200;                    % sampling frequency (Hz)
T = 1;                       % recording length (s)
t = 0:1/fs:T-1/fs;

x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*40*t);

% Single-sided amplitude spectrum
N = length(x);
Y = fft(x);

P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:N/2)/N;

% Bin spacing and the two largest peaks
df = fs/N;
fprintf('N = %d samples, bin spacing = %.2f Hz\n', N, df);
[pk, idx] = maxk(P1, 2);
fprintf('Peak at %.2f Hz, amplitude %.4f\n', [f(idx); pk]);

% Time-domain plot
figure;
plot(t, x);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Two-frequency signal in the time domain');
saveas(gcf, 'two-frequency-signal.png');

% Spectrum plot
figure;
plot(f, P1);
grid on;
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Single-sided amplitude spectrum');
saveas(gcf, 'two-frequency-spectrum.png');
