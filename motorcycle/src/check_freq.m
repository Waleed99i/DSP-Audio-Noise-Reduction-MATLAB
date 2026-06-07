clc; clear;
[x,fs] = audioread('DSP_MOTORCYCLE.wav');
if size(x,2)>1
   x = mean(x,2);
end
N = length(x);
X = abs(fft(x));
f = (0:N-1)*(fs/N);
% only examine 0-1000 Hz
idx = f <= 1000;
Xlow = X(idx);
flow = f(idx);
% find peaks
[pks,locs] = findpeaks(Xlow,...
   'MinPeakHeight',max(Xlow)*0.05,...
   'MinPeakDistance',20);
% sort strongest peaks
[pksSorted,I] = sort(pks,'descend');
numPeaks = min(20,length(I));
fprintf('\nStrongest Frequency Peaks (BIKE):\n');
fprintf('--------------------------\n');
for k = 1:numPeaks
   fprintf('%2d : %.2f Hz   Magnitude = %.2f\n',...
       k,...
       flow(locs(I(k))),...
       pksSorted(k));
end
