clear all;
close all;
warning off;

%% Definition of variables 
N=1000; %Frame length/ DFT size. N must be even
fs = 30e3; %sample freq
Nq = 2; %QAM modulation size
prefix_value = 100+1;
Lt = 10;% number of training
trainingFramesNum = Lt;%should be longer than the impulse response  frames 
%% qamstream generation
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);
% Check remainder 
remainder = mod(length(qamStream),(N/2 -1));

%% Channel estimation
trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=repmat(trainblock,trainingFramesNum,1);  %repeating the vector trainingFramesNum times
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation

%% OFDM modulation 
[ofdmStream,trainpacket,lenDataPackage] = ofdm_mod7(qamStream,N,true,prefix_value,remainder,trainblock,Lt);
%% Real channel  
t=0:1/fs:1000/fs;
pulse=(1).*sin(2*pi*800*t); %short sine function is a good pulse
[simin,nbsecs,~,toplay]=initparams_7(ofdmStream,fs,pulse); %Calls for function initparams.m
sim('recplay');
out=simout.signals.values;
%% Signal Alignment 
Rx = alignIO7(out(:,1), pulse,fs);
Rx = Rx(1:length(ofdmStream),1);
%% OFDM Demodulation 
[Y,H_k] = ofdm_demod7(Rx,N,true,prefix_value,remainder,trainpacket,Lt,lenDataPackage,Nq);
%% QAM Demodulation
rxBitStream = qam_demod(Y,Nq,'bin',true);
%% Data visualisation 
visualize_demod7(H_k,N,fs,imageData,colorMap,prefix_value,rxBitStream,Nq);
%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream)

