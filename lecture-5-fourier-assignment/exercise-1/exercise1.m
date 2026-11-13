%% Exercise 1 - Build a square wave from odd harmonics
clear; clc; close all;

t = linspace(-1, 1, 4000);
Hlist = [1 3 9 25];          % highest harmonic in each test

figure;
for i = 1:length(Hlist)
    H = Hlist(i);
    x = zeros(size(t));

    % add the odd harmonics 1, 3, 5, ... up to H
    for k = 1:2:H
        x = x + (4/pi) * sin(2*pi*k*t) / k;
    end

    subplot(2,2,i);
    plot(t, x);
    grid on;
    ylim([-1.5 1.5]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Square wave approximation, H = ', num2str(H)]);

    fprintf('H = %2d: maximum value = %.4f\n', H, max(x));
end

saveas(gcf, 'square-wave-comparison.png');
