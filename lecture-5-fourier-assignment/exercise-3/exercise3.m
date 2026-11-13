%% Exercise 3 - Investigate spectral leakage
clear; clc; close all;

d = 3;                       % last digit of my student number
f2 = 13.2 + 0.17*d;          % second frequency (Hz)
fs = 200;                    % sampling frequency (Hz)

fprintf('d = %d, f2 = %.2f Hz\n', d, f2);

% Three cases: 1 s, 4 s, and 1 s zero-padded to four times the length
names   = {'1 s recording', '4 s recording', '1 s recording, zero-padded (4x)'};
Tlist   = [1 4 1];           % recording length (s)
padList = [1 1 4];           % FFT length = padList * number of samples

figure;
for c = 1:3
    t = 0:1/fs:Tlist(c)-1/fs;
    x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*f2*t);

    N = length(x);           % real number of samples
    Nfft = padList(c)*N;     % Nfft > N means zero-padding
    Y = fft(x, Nfft);

    P2 = abs(Y/N);           % divide by N so the amplitudes stay comparable
    P1 = P2(1:Nfft/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:Nfft/2)/Nfft;

    % highest point within 1 Hz of f2 (this leaves out the 15 Hz peak)
    near = abs(f - f2) < 1;
    fNear = f(near);
    [pk, ip] = max(P1(near));
    fprintf('%s: bin spacing %.2f Hz, peak near f2 = %.4f at %.2f Hz\n', names{c}, fs/Nfft, pk, fNear(ip));

    subplot(3,1,c);
    plot(f, P1, '.-');
    grid on;
    xlim([0 30]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title(names{c});
end

saveas(gcf, 'leakage-comparison.png');
