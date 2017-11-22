%%% Milestone 2b %%%

% Exercise session 4: DMT-OFDM transmission scheme.
% QAM- and OFDM-modulation. On-off bit loading.

clear all;
close all;
load('IRest.mat')
channel_IR = h;

% Constants for OFDM/QAM
Nq=6; %QAM constellation size, max 6
prefix_value = length(h)+1; %prefix value needs to be longer than IR
SNR=20; %Signal to noise ratio
L=10; %channel order
N=1e3; %DFT size, N must be even
N_kept = 20; %Nr of frequency bins used for exercise 4.3
             %Smaller N_kept gives lower BER but longer transmission time
eq = fft(h,N); %scaling/equalization factor

%plotting DFT of impulse response
fourier_sig = mag2db(abs(eq));
plot(fourier_sig);
title('DFT of IR (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on

%Listing the N_kept best (highest value) frequency bins
[sorted_arry,index_array] = sort(abs(eq(1:N/2)),'descend');
new_index_array = index_array(1:N_kept);
new_index_array = sort(new_index_array,'ascend');

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);

% Check remainder of qamstream length and packet size in OFDM modulation
remainder = mod(length(qamStream),(N/2 -1));
remainder_on_off = mod(length(qamStream),(N_kept));

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,N,true,prefix_value,remainder); 
ofdmStream_on_off = ofdm_mod_on_off(qamStream,N,true,prefix_value,remainder_on_off,new_index_array); 

% Channel with true impulse response 
rxOfdmStream = filter(h,1,ofdmStream);
rxOfdmStream_on_off = filter(h,1,ofdmStream_on_off);

% Adding white noise
rxOfdmStream = awgn(rxOfdmStream, SNR, 'measured');
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

% Plot images for regular transmission
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

% Plot images for ON OFF bit loading
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image ON OFF bit loading'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx_on_off); axis image; title('Received image ON OFF bit loading'); drawnow;