% 2023-EE-165

clc;
clear;
close all;

%%  LOAD AUDIO 
[x, fs] = audioread('DSP_QAWALI.wav');

if size(x,2) > 1
    x = mean(x,2);
end

x = x / max(abs(x));

t = (0:length(x)-1)/fs;

sound(x, fs);
pause(8);

%%  STEP 1: FFT 
N = length(x);
X = fft(x);

mag = abs(X);
phase = angle(X);

%%  STEP 2: NOISE ESTIMATION 
% smooth spectrum → estimate qawali/background energy
noise_mag = movmean(mag, 150);

%%  STEP 3: AGGRESSIVE SPEECH ENHANCEMENT 
alpha = 1.5;   % stronger suppression

clean_mag = mag - alpha * noise_mag;

% avoid negative values
clean_mag(clean_mag < 0) = 0;

%%  STEP 4: RECONSTRUCTION 
Y = clean_mag .* exp(1j * phase);

y = real(ifft(Y));

%%  STEP 5: POST PROCESS 
y = movmean(y, 3);   % light smoothing only
y = y / max(abs(y));

%%  OUTPUT 
disp('Cleaned Audio Playing...');
sound(y, fs);

audiowrite('CLEANED_QAWALI.wav', y, fs);

%% 1st Plot
figure;
subplot(2,1,1);
plot(t,x);
title('Original Qawali Mix');

subplot(2,1,2);
plot(t,y);
title('Enhanced Speech (Target Voice Boosted)');

%% 2nd FFT PEAK COMPARISON (SINGLE PLOT) 

N = length(x);

% FFT of original and cleaned
X1 = abs(fft(x));
X2 = abs(fft(y));

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

title('Frequency Spectrum: Qawali Removal Comparison');
xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');
legend('Original Qawali Mix (Red)', 'Cleaned Speech (Blue)');
grid on;
xlim([0 2000]); % speech + music range focus

%% 3rd

figure;
spectrogram(x,256,200,256,fs,'yaxis');
title('Original');

%% 4th

figure;
spectrogram(y,256,200,256,fs,'yaxis');
title('Cleaned Output');

disp('DONE');
