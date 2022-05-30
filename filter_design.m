i = 1
toRead = strcat('songDatabase/', num2str(i),'.mat')
load(toRead, '-mat');
y = y(:,1);
y = resample(y,8000,Fs);
% clipLength(i) = length(y)/Fs;
new_Fs =8000;
L = length(y);
% t = (0 : L-1)/Fs;
% x = chirp(t,10,.5,100);
NFFT = 2^nextpow2(L); 
Y = fft(y,NFFT)/L;
f = new_Fs / 2 * linspace(0,1,NFFT/2+1);
subplot(311)
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Amplitude Spectrum of Noise-free Signal')
xlabel('Frequency (Hz)')
toRead = strcat('songHighNoise1/', num2str(i),'Noise.mat')
load(toRead, '-mat');
y = y(:,1);
y = resample(y,new_Fs,Fs);
% clipLength(i) = length(y)/Fs;
L = length(y);
% t = (0 : L-1)/Fs;
% x = chirp(t,10,.5,100);
NFFT = 2^nextpow2(L); 
Y = fft(y,NFFT)/L;
f = new_Fs / 2 * linspace(0,1,NFFT/2+1);
subplot(312)
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Amplitude Spectrum of Noisy Signal')
xlabel('Frequency (Hz)')


newx = lowpass(y, 2000, new_Fs);
% sound(newx, 8000);
newY = fft(newx,NFFT)/L;
subplot(313);
plot(f,2*abs(newY(1:NFFT/2+1))) 
title('Amplitude Spectrum of Low band pass Noisy Signal')
xlabel('Frequency (Hz)')

% b = fir2(30,[0 2*50 2*50 Fs]/Fs,[1 1 0 0]);
% n = randn(L, 1);
% nb = filter(b,1,n);
% newx = x + nb' .* cos(2*pi*300*t);         % x + modulated noise (Fc = 300Hz)
% newY = fft(newx,NFFT)/L;
% subplot(212)
% plot(f,2*abs(newY(1:NFFT/2+1))) 
% title('Amplitude Spectrum of Noisy Signal')
% xlabel('Frequency (Hz)')