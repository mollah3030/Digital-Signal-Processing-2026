%% Lecture 06 - FIR and IIR filtering of a sensor signal and a 50 Hz audio hum
% Md Mohiuddin Mollah - Digital Signal Processing 2026
% Needs the Signal Processing Toolbox (fir1, butter, freqz, filtfilt).
clear; clc; close all;

playAudio = false;           % set to true to listen to the audio in Part B

fprintf('MATLAB version: %s\n', version);
fprintf('Signal Processing Toolbox available: %d\n', license('test', 'Signal_Toolbox'));

%% Part A - Filter a sensor signal
Fs = 1000;                   % sampling frequency (Hz)
t = (0:1/Fs:2-1/Fs)';        % two seconds

rng(7);
clean = sin(2*pi*5*t) + 0.35*sin(2*pi*12*t);
noise = 0.35*sin(2*pi*50*t) + 0.20*sin(2*pi*137*t) + 0.25*randn(size(t));
x = clean + noise;

% Two low-pass filters with a 20 Hz cutoff
fc = 20;
bFIR = fir1(60, fc/(Fs/2), 'low');
[bIIR, aIIR] = butter(4, fc/(Fs/2), 'low');

% Zero-phase (offline) filtering
yFIR = filtfilt(bFIR, 1, x);
yIIR = filtfilt(bIIR, aIIR, x);

fprintf('\nPART A\n');
fprintf('FIR coefficients: %d, IIR coefficients: %d (b) + %d (a)\n', numel(bFIR), numel(bIIR), numel(aIIR));

%% A1 - Time-domain comparison over a 0.2 s section
idx = t >= 1 & t < 1.2;
figure;
plot(t(idx), x(idx), 'Color', [0.7 0.7 0.7]); hold on;
plot(t(idx), clean(idx), 'k', 'LineWidth', 1.5);
plot(t(idx), yFIR(idx), 'b--', 'LineWidth', 1.3);
plot(t(idx), yIIR(idx), 'r:', 'LineWidth', 1.8);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Sensor signal: noisy input, clean reference and filter outputs');
legend('Noisy input', 'Clean reference', 'FIR output', 'IIR output');
saveas(gcf, 'sensor_time_comparison.png');

%% A2 - Magnitude responses
[hFIR, fAxis] = freqz(bFIR, 1, 4096, Fs);
hIIR = freqz(bIIR, aIIR, 4096, Fs);
figure;
plot(fAxis, 20*log10(abs(hFIR)), 'b', 'LineWidth', 1.3); hold on;
plot(fAxis, 20*log10(abs(hIIR)), 'r', 'LineWidth', 1.3);
xline(fc, 'k--', '20 Hz cutoff');
grid on; xlim([0 200]); ylim([-120 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Magnitude responses of the low-pass filters (single pass)');
legend('FIR, order 60 (61 taps)', 'Butterworth IIR, order 4', 'Location', 'southwest');
saveas(gcf, 'sensor_frequency_responses.png');

% Gain of each filter at the important frequencies
fTest = [5 12 20 50 137];
gFIR = 20*log10(abs(freqz(bFIR, 1, fTest, Fs)));
gIIR = 20*log10(abs(freqz(bIIR, aIIR, fTest, Fs)));
fprintf('Single-pass gain in dB (filtfilt doubles these values):\n');
for k = 1:numel(fTest)
    fprintf('  %3d Hz: FIR %8.2f dB, IIR %8.2f dB\n', fTest(k), gFIR(k), gIIR(k));
end

%% A3 - Single-sided amplitude spectra
N = length(x);
f = Fs*(0:N/2)/N;
sigs = {x, yFIR, yIIR};
sigNames = {'Noisy input', 'FIR output', 'IIR output'};
fCheck = [5 12 50 137];
figure;
for k = 1:3
    Y = fft(sigs{k});
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    subplot(3,1,k);
    plot(f, P1);
    grid on; xlim([0 200]); ylim([0 1.1]);
    xlabel('Frequency (Hz)'); ylabel('Amplitude');
    title(['Single-sided amplitude spectrum: ', sigNames{k}]);

    % the bin spacing is 0.5 Hz, so each test frequency is exactly on a bin
    fprintf('%-12s amplitude at 5/12/50/137 Hz: %.4f  %.4f  %.4f  %.4f\n', sigNames{k}, P1(round(fCheck*N/Fs)+1));
end
saveas(gcf, 'sensor_spectra.png');

%% A4 - RMSE against the known clean signal
mid = t >= 0.2 & t < 1.8;    % middle part, away from the edges
edge = t < 0.1;              % first 0.1 s
rmseAll = @(s) sqrt(mean((s - clean).^2));
rmseMid = @(s) sqrt(mean((s(mid) - clean(mid)).^2));
rmseEdge = @(s) sqrt(mean((s(edge) - clean(edge)).^2));
fprintf('RMSE (whole signal / middle / first 0.1 s):\n');
fprintf('  Noisy input: %.4f / %.4f / %.4f\n', rmseAll(x), rmseMid(x), rmseEdge(x));
fprintf('  FIR output : %.4f / %.4f / %.4f\n', rmseAll(yFIR), rmseMid(yFIR), rmseEdge(yFIR));
fprintf('  IIR output : %.4f / %.4f / %.4f\n', rmseAll(yIIR), rmseMid(yIIR), rmseEdge(yIIR));

%% Part B - Reduce a 50 Hz hum in audio
S = load('handel');          % provides y and Fs
FsA = S.Fs;
xClean = S.y(:);
tAudio = (0:numel(xClean)-1)'/FsA;

% Add a controlled 50 Hz hum, so the clean signal is known
xHum = xClean + 0.15*sin(2*pi*50*tAudio);

% Narrow band-stop filter around 50 Hz
[bN, aN] = butter(2, [48 52]/(FsA/2), 'stop');
yAudio = filtfilt(bN, aN, xHum);

% Wider band-stop filter for comparison
[bW, aW] = butter(2, [45 55]/(FsA/2), 'stop');
yWide = filtfilt(bW, aW, xHum);

fprintf('\nPART B\n');
fprintf('Audio sample rate: %d Hz (must be above 102 Hz), length: %.2f s\n', FsA, numel(xClean)/FsA);

%% B measurements
% 50 Hz amplitude: correlate the signal with a 50 Hz complex exponential
amp50 = @(s) 2*abs(mean(s .* exp(-1j*2*pi*50*tAudio)));
rmseA = @(s) sqrt(mean((s - xClean).^2));

aHum = amp50(xHum);
fprintf('50 Hz amplitude: clean %.5f, with hum %.5f, narrow filter %.5f, wide filter %.5f\n', amp50(xClean), aHum, amp50(yAudio), amp50(yWide));
fprintf('Measured 50 Hz reduction: narrow %.1f dB, wide %.1f dB\n', 20*log10(amp50(yAudio)/aHum), 20*log10(amp50(yWide)/aHum));
fprintf('RMSE against clean audio: with hum %.5f, narrow %.5f, wide %.5f\n', rmseA(xHum), rmseA(yAudio), rmseA(yWide));

% Useful audio removed: filter the clean audio itself and measure the change
lossN = sqrt(mean((xClean - filtfilt(bN, aN, xClean)).^2));
lossW = sqrt(mean((xClean - filtfilt(bW, aW, xClean)).^2));
fprintf('RMS of clean audio removed by the filter: narrow %.5f, wide %.5f\n', lossN, lossW);

% Filter gain at some frequencies (single pass; filtfilt doubles the dB value)
fNotch = [40 45 48 50 52 55 60 100];
gN = 20*log10(abs(freqz(bN, aN, fNotch, FsA)));
gW = 20*log10(abs(freqz(bW, aW, fNotch, FsA)));
for k = 1:numel(fNotch)
    fprintf('  %3d Hz: narrow %8.2f dB, wide %8.2f dB\n', fNotch(k), gN(k), gW(k));
end

%% B1 - Waveform before and after (same axes)
seg = tAudio >= 1 & tAudio < 1.1;
yl = 1.1*max(abs(xHum(seg)));
trio = {xClean, xHum, yAudio};
trioNames = {'Clean audio', 'Audio with 50 Hz hum added', 'After the 48-52 Hz band-stop filter'};
figure;
for k = 1:3
    subplot(3,1,k);
    plot(tAudio(seg), trio{k}(seg));
    grid on; ylim([-yl yl]);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(trioNames{k});
end
saveas(gcf, 'audio_waveform_comparison.png');

%% B2 - Low-frequency spectrum of the audio signals
NA = numel(xClean);
half = floor(NA/2);
fA = FsA*(0:half)/NA;
quad = {xClean, xHum, yAudio, yWide};
styles = {'k', 'r', 'b', 'g--'};
figure;
for k = 1:4
    P2 = abs(fft(quad{k})/NA);
    P1 = P2(1:half+1);
    P1(2:end) = 2*P1(2:end);
    plot(fA, 20*log10(P1 + 1e-12), styles{k}); hold on;
end
xline(50, 'k:', '50 Hz');
grid on; xlim([0 200]); ylim([-140 0]);
xlabel('Frequency (Hz)'); ylabel('Amplitude (dB)');
title('Audio spectrum below 200 Hz');
legend('Clean', 'With hum', 'Narrow 48-52 Hz filter', 'Wide 45-55 Hz filter', 'Location', 'northeast');
saveas(gcf, 'audio_spectrum.png');

%% B3 - Band-stop filter responses
fZoom = linspace(20, 80, 2000);
figure;
plot(fZoom, 20*log10(abs(freqz(bN, aN, fZoom, FsA))), 'b', 'LineWidth', 1.3); hold on;
plot(fZoom, 20*log10(abs(freqz(bW, aW, fZoom, FsA))), 'r', 'LineWidth', 1.3);
xline(50, 'k:', '50 Hz');
grid on; ylim([-80 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Band-stop filter responses (single pass)');
legend('48-52 Hz stop band', '45-55 Hz stop band', 'Location', 'southeast');
saveas(gcf, 'notch_response.png');

%% Listening test: same playback gain for both signals
if playAudio
    g = 0.9/max(abs(xHum));
    sound(g*xHum, FsA);   pause(numel(xHum)/FsA + 1);
    sound(g*yAudio, FsA); pause(numel(xHum)/FsA + 1);
end
