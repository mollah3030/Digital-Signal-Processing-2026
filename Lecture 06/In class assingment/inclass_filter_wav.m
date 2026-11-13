%% In-class task: inspect and filter a WAV file
% Md Mohiuddin Mollah - Digital Signal Processing 2026 (worked on together with a classmate)
% Needs MATLAB with the Signal Processing Toolbox (butter, filtfilt, pwelch).
clear; clc; close all;

%% 0. SETTINGS - edit these
fileName   = 'hum_music.wav';   % your WAV file, in the same folder as this script
plotStart  = 1.0;           % start of the short section to plot (s)
plotLen    = 0.5;           % length of that section (s)
doPlayback = false;         % set to true to hear both versions

% Filter choice: fill these in AFTER you have looked at Figure 1.
filterType = 'bandstop';    % 'bandstop' | 'lowpass' | 'highpass'
cutoffHz   = [45 55];       % bandstop: [low high]. lowpass/highpass: one number, e.g. 8000
order      = 4;             % Butterworth order (filtfilt applies it twice)
usefulBand = [300 3400];    % band of the sound you want to keep (speech example)

%% 1. LOAD AND CHECK THE FILE
info = audioinfo(fileName);
[y, fs] = audioread(fileName);          % y: samples x channels
nCh = size(y, 2);
dur = size(y, 1) / fs;
fprintf('File: %s\n', fileName);
fprintf('Sample rate : %d Hz\n', fs);
fprintf('Duration    : %.2f s\n', dur);
fprintf('Channels    : %d\n', nCh);
fprintf('Bits/sample : %d\n', info.BitsPerSample);

x = mean(y, 2);                          % mono mix, used for plots and analysis
t = (0:size(y,1)-1)' / fs;
nyq = fs / 2;

% keep the plotted section inside the file
plotLen   = min(plotLen, dur);
plotStart = min(plotStart, dur - plotLen);
idx = t >= plotStart & t < plotStart + plotLen;

%% 2. INSPECT: waveform, spectrogram, average spectrum  (Figure 1)
[pxx, f] = pwelch(x, hann(4096), 2048, 4096, fs);
pdb = 10*log10(pxx + eps);

figure(1); set(gcf, 'Name', 'Inspection', 'Position', [100 100 900 800]);
subplot(3,1,1);
plot(t(idx), x(idx)); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title(sprintf('Waveform, %.2f s section', plotLen));

subplot(3,1,2);
spectrogram(x, hann(1024), 768, 1024, fs, 'yaxis');
title('Spectrogram of the whole file');

subplot(3,1,3);
plot(f, pdb); grid on;
xlabel('Frequency (Hz)'); ylabel('Power (dB/Hz)');
title('Average spectrum (look for steady peaks, or too much energy at the top/bottom)');
xlim([0 nyq]);

% Help for finding hum: strongest steady peaks below 1 kHz
mask = f < 1000;
[pks, locs] = findpeaks(pdb(mask), f(mask), 'MinPeakProminence', 10, 'SortStr', 'descend');
fprintf('\nStrongest narrow peaks below 1 kHz:\n');
for k = 1:min(5, numel(locs))
    fprintf('  %.1f Hz  (%.1f dB/Hz)\n', locs(k), pks(k));
end
if isempty(locs), fprintf('  none found\n'); end

%% 3. DESIGN AND APPLY THE FILTER
assert(all(cutoffHz > 0 & cutoffHz < nyq), 'Cutoff must be between 0 and fs/2 = %d Hz', nyq);
switch filterType
    case 'bandstop'
        assert(numel(cutoffHz) == 2, 'bandstop needs [low high]');
        [z, p, k] = butter(order, cutoffHz / nyq, 'stop');
        unwanted = cutoffHz;
    case 'lowpass'
        [z, p, k] = butter(order, cutoffHz(1) / nyq, 'low');
        unwanted = [cutoffHz(1), nyq - 1];
    case 'highpass'
        [z, p, k] = butter(order, cutoffHz(1) / nyq, 'high');
        unwanted = [1, cutoffHz(1)];
    otherwise
        error('filterType must be bandstop, lowpass or highpass');
end
[sos, g] = zp2sos(z, p, k);              % second-order sections: numerically stable
yf = filtfilt(sos, g, y);                % zero-phase filtering on every channel
xf = mean(yf, 2);

fprintf('\nFilter: Butterworth %s, order %d (x2 with filtfilt), cutoff = %s Hz\n', ...
        filterType, order, mat2str(cutoffHz));

%% 4. COMPARE: same scales for both  (Figure 2)
ymax = max(abs([x(idx); xf(idx)])) * 1.1;
[S1, ~, ~] = spectrogram(x,  hann(1024), 768, 1024, fs);
[S2, ~, ~] = spectrogram(xf, hann(1024), 768, 1024, fs);
db1 = 20*log10(abs(S1) + eps);  db2 = 20*log10(abs(S2) + eps);
top = max([db1(:); db2(:)]);
cl  = [top - 90, top];                    % same colour range for both spectrograms

figure(2); set(gcf, 'Name', 'Original vs filtered', 'Position', [100 100 1100 700]);
subplot(2,2,1); plot(t(idx), x(idx));  ylim([-ymax ymax]); grid on;
title('Original waveform'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(2,2,2); plot(t(idx), xf(idx)); ylim([-ymax ymax]); grid on;
title('Filtered waveform'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(2,2,3); spectrogram(x,  hann(1024), 768, 1024, fs, 'yaxis'); caxis(cl);
title('Original spectrogram');
subplot(2,2,4); spectrogram(xf, hann(1024), 768, 1024, fs, 'yaxis'); caxis(cl);
title('Filtered spectrogram');
sgtitle(sprintf('%s, cutoff %s Hz', filterType, mat2str(cutoffHz)));

% Average spectra on top of each other  (Figure 3)
[pxf, ~] = pwelch(xf, hann(4096), 2048, 4096, fs);
figure(3); set(gcf, 'Name', 'Spectrum before/after');
plot(f, pdb, f, 10*log10(pxf + eps)); grid on;
xlabel('Frequency (Hz)'); ylabel('Power (dB/Hz)'); xlim([0 nyq]);
legend('Original', 'Filtered');
title('Average spectrum before and after filtering');

%% 5. NUMBERS: unwanted band down, useful band kept?
ub = [unwanted(1), min(unwanted(2), nyq - 1)];
ub_before = 10*log10(bandpower(x,  fs, ub));
ub_after  = 10*log10(bandpower(xf, fs, ub));
us_before = 10*log10(bandpower(x,  fs, usefulBand));
us_after  = 10*log10(bandpower(xf, fs, usefulBand));
fprintf('\nUnwanted band %s Hz : %.1f dB -> %.1f dB (change %.1f dB)\n', ...
        mat2str(ub), ub_before, ub_after, ub_after - ub_before);
fprintf('Useful band   %s Hz : %.1f dB -> %.1f dB (change %.1f dB)\n', ...
        mat2str(usefulBand), us_before, us_after, us_after - us_before);

%% 6. PLAYBACK with the same gain for both
gain = 0.9 / max(abs([y(:); yf(:)]));     % one gain for both, no clipping
if doPlayback
    fprintf('\nPlaying original...\n');
    playblocking(audioplayer(gain * y,  fs));
    pause(0.7);
    fprintf('Playing filtered...\n');
    playblocking(audioplayer(gain * yf, fs));
end

%% 7. SAVE OUTPUTS
try
    exportgraphics(figure(2), 'comparison.png', 'Resolution', 200);
catch
    saveas(figure(2), 'comparison.png');
end
audiowrite('filtered.wav', gain * yf, fs);
fprintf('\nSaved comparison.png and filtered.wav\n');
