clear all;
close all;
tic
load('IRest.mat')
channel_IR = h;
%% Definition of variables 
N=500; %Frame length/ DFT size. N must be even
N_kept = 20; %For ON-OFF bit loading 
eq = fft(h,N);
fs = 8e3; %sample freq
Nq = 3; %QAM modulation size
SNR=20; %Signal to noise ratio
L=10; %channel order
prefix_value = length(h)+1; %should be longer than the impulse response
Lt = 20; % number of training frames 
Ld = 20; % number of data frames
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
[ofdmStream,trainpacket,div_Ld,Mod_Ld] = ofdm_mod_training(qamStream,N,true,prefix_value,remainder,trainblock,Lt,Ld); 
%%
%%% Real channel %%%

t=0:1/fs:1000/fs;
pulse=(0.8).*sin(2*pi*800*t); %short sine function is a good pulse

%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(ofdmStream,fs,pulse); %Calls for function initparams.m
sim('recplay2');
out=simout.signals.values;
%%
Rx = alignIO(out(:,1), pulse,fs);
Rx = Rx(1:length(ofdmStream),1);
% % Channel with true impulse response
% rxOfdmStream = filter(h,1,ofdmStream);
% % Adding white noise
% Rx = awgn(rxOfdmStream, SNR, 'measured'); %%%% ALWAYS ADD 'measured'
%% OFDM demodulation + equalization
[rxQamStream,H_k] = ofdm_demod_training(Rx,N,true,prefix_value,remainder,trainpacket,Lt,Ld,div_Ld,Mod_Ld);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream,Nq,'bin',true);

%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

toc