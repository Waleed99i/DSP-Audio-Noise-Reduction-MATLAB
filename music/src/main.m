% 2023-EE-165

clc;
clear;
close all;

%%  LOAD AUDIO 
[x, fs] = audioread('DSP_MUSIC.wav');

if size(x,2) > 1
    x = mean(x,2);
end

x = x / max(abs(x));

t = (0:length(x)-1)/fs;

sound(x, fs);
pause(8);

%%  STEP 1: NOTCH FILTERS (FROM PEAKS) 
% Remove strongest  frequencies

freqs = [128 132 139 145 149 155 ...
         260 265 272 277 284 288 290 ...
         410 413 420 425 431 437 ...
         564 570 572];

y = x;

for i = 1:length(freqs)
    f0 = freqs(i);
    
    bw = 5; % bandwidth (adjustable)

    w0 = f0/(fs/2);

    [b,a] = iirnotch(w0, bw/(fs/2));

    y = filter(b,a,y);
end

%%  STEP 2: MILD BAND LIMIT (SPEECH PROTECTION) 
[b,a] = butter(4, [80 3400]/(fs/2), 'bandpass');
y = filter(b,a,y);

%%  STEP 3: WIENER STYLE SMOOTHING 
frame = 2460;
y2 = movmean(y, frame);

%%  NORMALIZE 
y2 = y2 / max(abs(y2));

%%  OUTPUT 
disp('Clean Audio Playing...');
sound(y2, fs);

audiowrite('CLEANED_MUSIC.wav', y2, fs);

%% PLOTS 
figure;
subplot(3,1,1);
plot(t,x); title('Original');

subplot(3,1,2);
plot(t,y); title('After Notch Filtering');

subplot(3,1,3);
plot(t,y2); title('Final Clean Output');

%%  FFT PEAK COMPARISON (SINGLE PLOT) 

N = length(x);

% FFT of original and cleaned
X1 = abs(fft(x));
X2 = abs(fft(y2));

f = (0:N-1)*(fs/N);

% keep only first half (important)
half = 1:floor(N/2);

f = f(half);
X1 = X1(half);
X2 = X2(half);

% normalize for fair comparison
X1 = X1 / max(X1);
X2 = X2 / max(X2);

figure;

plot(f, X1, 'r', 'LineWidth', 1.2); hold on;
plot(f, X2, 'b', 'LineWidth', 1.2);

title('Frequency Spectrum(MUSIC): Original vs Cleaned');
xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');
legend('Original (Red)', 'Cleaned (Blue)');
grid on;
xlim([0 2000]); % focus on speech + noise range

%%  SPECTROGRAM 
figure;
spectrogram(x,256,200,256,fs,'yaxis');
title('Original');

figure;
spectrogram(y2,256,200,256,fs,'yaxis');
title('Final Clean');

disp('DONE');