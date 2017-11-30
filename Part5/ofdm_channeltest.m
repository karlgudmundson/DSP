clear all;
close all;
load('IRest.mat')
%h=h_IR2;

%Constants
fs = 44100; %sample freq
N = 500; %DFT size
Nq = 4; %QAM modulation size
trainingFramesNum = 100; %% number of training frames 
prefix_value = length(h)+1; %should be longer than the impulse response
trainblock=randi([0 1], (N/2-1)*Nq, 1);
bitStream =repmat(trainblock,trainingFramesNum,1); %random bitstream with a length 
% such that you can be sure that you have a N/2 -1 qam sequence by
% modulating this bitstream 
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1); %repeating the vector trainingFramesNum times

%%%% OFDM modulation %%%%%%
remainder = mod(length(trainblock),(N/2 -1)); % a pripori not required 
Tx=ofdm_mod(trainblock,N,true,prefix_value,remainder); %ofdm modulation

%%% Real channel %%%

t=0:1/fs:100/fs;
pulse=10*sin(2*pi*800*t); %short sine function is a good pulse

%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(Tx,fs,pulse); %Calls for function initparams.m
sim('recplay');
out=simout.signals.values;

Rx = alignIO(out, pulse,fs);
Rx = Rx(1:length(Tx),1);
%%% Channel %%%%%%
%Rx = filter(h,1,Tx);

%%%% OFDM Demodulation %%%%%%
trainblock = reshape(trainblock,N/2-1,[]);
trainblock_star = conj(trainblock);
trainblock = [zeros(1,size(trainblock,2)); trainblock ; zeros(1,size(trainblock,2)) ; flipud(trainblock_star)];
[Rx_demod,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainder,trainblock);

%%%% QAM demod %%%
rxBitStream = qam_demod(Rx_demod,Nq,'bin',true);

%%% BER computation %%%
[berTransmission] = ber(bitStream,rxBitStream);


%%%% plotting the channel impusle response measured 
fourier_sig = fftshift(fft(h,N)) %%% define the DFT size 
figure
subplot(2,1,1)
plot(h)
title('IR2 in time domain (2nd method)')
xlabel('samples [n]');
ylabel('amplitude');
grid on
subplot(2,1,2)
k = 0:1:N-1;
f_axis = fs*k/N -fs/2;
fourier_sig = mag2db(abs(fourier_sig));
plot(f_axis,fourier_sig);
title('DFT of IR2 (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on
time_IR_est = ifft(IR_freq_est)
fourier_sig = IR_freq_est;
figure
subplot(2,1,1)
plot(time_IR_est(1:400))
title(' Estimated IR based on the ODFDM estimation with training sequence in time domain')
xlabel('samples [n]');
ylabel('amplitude');
grid on
subplot(2,1,2)
fourier_sig = mag2db(abs(fourier_sig));
plot(f_axis, fftshift(fourier_sig));
title('Frequency response of estimated IR based on the ODFDM with training sequence');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on





