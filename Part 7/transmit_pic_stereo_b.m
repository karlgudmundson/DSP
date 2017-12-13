clear all; close all;
% First exercicse for PART II
%% random transfer functions 
stereo_channel_est;
%% Definition of variables 
N=1000; %Frame length/ DFT size. N must be even
fs = 20e3; %sample freq
Nq = 4; %QAM modulation size
prefix_value = 400+1;
Lt = 5;% number of training
Ld = 10;
trainingFramesNum = Lt;%should be longer than the impulse response  frames 
H_1_omega = H_tot(:,1);
H_2_omega = H_tot(:,2);
H_1_omega(1) = 1e-6 + j*1e-6;;
H_1_omega(N/2 +1) = 1e-6 - j*1e-6;;
H_2_omega(1) = 1e-6 + j*1e-6;;
H_2_omega(N/2 +1) = 1e-6 - j*1e-6;;
monotx=false; %monotransmission. true or false
speaker='c'; %speaker to use for transmission. 'a' or 'b' for right and
             %left speaker. c or any other character for both
SNR=20;
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
%% OFDM stereo modulation 
[ofdmStream,trainpacket,lenDataPackage,div_Ld,Mod_Ld] = ofdm_mod_stereo(qamStream,N,true,prefix_value,remainder,trainblock,Lt,H_1_omega,H_2_omega,monotx,speaker,Ld);
ofdmStream_b = ofdmStream(:,1);
ofdmStream_a = ofdmStream(:,2);

%% Real channel  
t=0:1/fs:1000/fs;
pulse=(0.8).*sin(2*pi*800*t); %short sine function is a good pulse
[simin,nbsecs,~,toplay]=initparams_stereo(ofdmStream,fs,pulse,speaker); %Calls for function initparams.m
sim('recplay2');
out=simout.signals.values;
%% Signal Alignment 
rxOfdmStream = alignIO7(out(:,1), pulse,fs);
rxOfdmStream = rxOfdmStream(1:length(ofdmStream),1);
%% OFDM Demodulation 
Y = ofdm_demod_stereo(rxOfdmStream,N,true,prefix_value,remainder,H_1_omega,H_2_omega,monotx,speaker,Lt,Ld,div_Ld,Mod_Ld,trainpacket);
%% QAM Demodulation
rxBitStream = qam_demod(Y,Nq,'bin',true);
%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream)
