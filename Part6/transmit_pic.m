clear all;
close all;
tic
load('IRest.mat')
channel_IR = h;
%% Definition of variables 
N=500; %Frame length/ DFT size. N must be even
N_kept = 20; %For ON-OFF bit loading 
eq = fft(h,N);
fs = 44100; %sample freq
Nq = 4; %QAM modulation size
SNR=20; %Signal to noise ratio
L=10; %channel order
prefix_value = length(h)+1; %should be longer than the impulse response
Lt = 10; % number of training frames 
Ld = 10; % number of data frames
%% qamstream generation

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));

%% Trainig part 
trainingFramesNum = Lt; %% number of training frames 
trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1);

%% OFDM Modulation 
ofdmStream = ofdm_mod_training(qamStream,N,true,prefix_value,remainder,trainblock,Lt,Ld); 
%%
%%% Real channel %%%

t=0:1/fs:100/fs;
pulse=10*sin(2*pi*800*t); %short sine function is a good pulse

%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(Tx,fs,pulse); %Calls for function initparams.m
sim('recplay');
out=simout.signals.values;

Rx = alignIO(out, pulse,fs);
Rx = Rx(1:length(Tx),1);
%% OFDM demodulation + equalization


rxQamStream = ofdm_demod(rxOfdmStream,N,true,prefix_value,remainder,eq);
rxQamStream_on_off = ofdm_demod_on_off(rxOfdmStream_on_off,N,true,prefix_value,remainder_on_off,eq,new_index_array);
% QAM demodulation
rxBitStream = qam_demod(rxQamStream,Nq,'bin',true);
rxBitStream_on_off = qam_demod(rxQamStream_on_off,Nq,'bin',true);

%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

toc