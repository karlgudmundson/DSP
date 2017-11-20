clear all;
close all;
load('IRest.mat')
channel_IR = h;
N=1e3; %N must be even
N_kept = 20;
eq = fft(h,N);
fourier_sig = mag2db(abs(eq));
plot(fourier_sig);
title('DFT of IR (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on

[sorted_arry,index_array] = sort(abs(eq(1:N/2)),'descend');
new_index_array = index_array(1:N_kept);
new_index_array = sort(new_index_array,'ascend');
% Exercise session 4: DMT-OFDM transmission scheme

% Constants
Nq=6; %max 6
prefix_value = length(h)+1; %% ti has just to be longer !!! 
SNR=10; %Signal to noise ratio
L=10; %channel order

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);

%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));
remainder_on_off = mod(length(qamStream),(N_kept));

% OFDM modulation
% input,length of packet N,prefix-> TRUE or FALSE, length of prefix,
% remainder
ofdmStream = ofdm_mod(qamStream,N,true,prefix_value,remainder); 
ofdmStream_on_off = ofdm_mod_on_off(qamStream,N,true,prefix_value,remainder_on_off,new_index_array); 
% Channel with a random TF
%num=randi([0 20],1,L);
%den=[1 zeros(1,L-1)];
%H=filt(num,den);
%num = -0.5:0.05:-0.05;
%num = -num
%rxOfdmStream = filter(num,1,ofdmStream);

% Channel with true impulse response 
rxOfdmStream = filter(h,1,ofdmStream);
rxOfdmStream_on_off = filter(h,1,ofdmStream_on_off);
noiseRxOfdmStream = rxOfdmStream;
% Adding white noise
rxOfdmStream = awgn(rxOfdmStream, SNR, 'measured'); %%%% ALWAYS ADD 'measured'
rxOfdmStream_on_off  = awgn(rxOfdmStream_on_off , SNR, 'measured');
% OFDM demodulation + equalization

rxQamStream = ofdm_demod(rxOfdmStream,N,true,prefix_value,remainder,eq);
rxQamStream_on_off = ofdm_demod_on_off(rxOfdmStream_on_off,N,true,prefix_value,remainder_on_off,eq,new_index_array);
% QAM demodulation
rxBitStream = qam_demod(rxQamStream,Nq,'bin',true);
rxBitStream_on_off = qam_demod(rxQamStream_on_off,Nq,'bin',true);

% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);
[berTransmission_on_off] = ber(bitStream,rxBitStream_on_off);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
imageRx_on_off = bitstreamtoimage(rxBitStream_on_off, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image ON OFF bit loading'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx_on_off); axis image; title(['Received image ON OFF bit loading']); drawnow;
