%CONSTANTS
f_sig=400;
fs_in=16000;
t=1/fs_in:1/fs_in:2;

%DIFFERENT DFT SIZES
%All dftsizes are scaled by 32
%dftsize=8
%dftsize=32
dftsize=128;
%dftsize=512

%DIFFERENT IN SIGNALS
sig=sin(2*pi*f_sig*t); %sig with specified frequency f
%sum of sines
%sig=sin(2*pi*50*t)+sin(2*pi*100*t)+sin(2*pi*200*t)+sin(2*pi*500*t)+sin(2*pi*1000*t)+sin(2*pi*2000*t)+sin(2*pi*4000*t)+sin(2*pi*6000*t);
%sig=rand(1,size(t,2)); %white noise

%RECORDING AND PLAYING
[simin,nbsecs,fs]=initparams(sig,fs_in);
sim('recplay');
out=simout.signals.values;
soundsc(out,fs);

%PLOTTING
%spectrogram
figure;
subplot(2,1,1);
spectrogram(simin(:,1),128*32,120*32,dftsize*32,fs_in); %scaling with 32
title('Spectrogram transmitted signal');
subplot(2,1,2);
spectrogram(out,128*32,120*32,dftsize*32,fs_in);
title('Spectrogram recorded signal');
%PSD
figure;
subplot(2,1,1);
pwelch(simin(:,1),128*32,120*32,dftsize*32,fs_in); %scaling with 32
title('Power Spectral density of transmitted signal');
subplot(2,1,2);
pwelch(out,128*32,120*32,dftsize*32,fs_in);
title('Power Spectral density of recorded signal');

%%%IMPULSE RESPONSE, SESSION 2%%%

%%%Toeplitz calculation. Sets size(h)=300, which corresponds to h in IR1%%%
A=toeplitz(sig,[sig(1) zeros(1,299)]);
delay=50; %50 sample positive delay
y=out(35500-delay+1:67500-delay); %out usually starts at sample ca 35500
h=A\y; %least squares solution

%%%Performs the DFT and calculates other properties for plotting h%%%
H=fft(h);
Hdb=mag2db(abs(H)); %converts the amplitude to decibel
f = (0:length(H)-1)*fs_in/length(H); 
samples=1:length(h); %nr of samples

%%%Plotting in time and frequency domain%%%
figure;
%Time domain
subplot(2,1,1);
plot(samples,h);
xlabel('Filter taps'); ylabel('Amplitude');
title('IR2 Time domain');
%Frequency domain
subplot(2,1,2);
plot(f(1:length(h)/2),Hdb(1:length(h)/2)); %Frequency spectrum divided by 2 because the graph is mirrored
grid on;
title('IR2 Frequency domain');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

