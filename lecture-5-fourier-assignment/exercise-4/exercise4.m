%% Exercise 4 - Compare the DTFT and the DFT
clear; clc; close all;

x = [1 1 1 1];
n = 0:length(x)-1;

% DTFT at 1000 frequency values between -pi and pi
w = linspace(-pi, pi, 1000);
X = x * exp(-1j * (n.' * w));

% DFT with 4 points and with 64 points (zero-padded)
X4 = fft(x, 4);
X64 = fft(x, 64);

% DFT bin frequencies, moved into the range -pi to pi
w4 = 2*pi*(0:3)/4;
w4(w4 >= pi) = w4(w4 >= pi) - 2*pi;
w64 = 2*pi*(0:63)/64;
w64(w64 >= pi) = w64(w64 >= pi) - 2*pi;

figure;
subplot(3,1,1);
plot(w, abs(X));
grid on; xlim([-pi pi]);
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
title('DTFT magnitude (1000 points)');

subplot(3,1,2);
plot(w, abs(X), 'Color', [0.7 0.7 0.7]); hold on;
stem(w4, abs(X4), 'filled');
grid on; xlim([-pi pi]);
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
title('fft(x,4) on top of the DTFT');
legend('DTFT', 'DFT, 4 points');

subplot(3,1,3);
plot(w, abs(X), 'Color', [0.7 0.7 0.7]); hold on;
stem(w64, abs(X64), 'filled');
grid on; xlim([-pi pi]);
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
title('fft(x,64) on top of the DTFT');
legend('DTFT', 'DFT, 64 points');

saveas(gcf, 'dtft-dft-comparison.png');

disp('Magnitude of fft(x,4):');
disp(abs(X4));
fprintf('Largest difference between fft(x,64) and the DTFT at the same frequencies: %.2e\n', max(abs(abs(X64) - abs(x * exp(-1j * (n.' * w64))))));
