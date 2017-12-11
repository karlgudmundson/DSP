clear all; close all;
% First exercicse for PART II
%% random transfer functions 
L = 80;
H_1 = rand(L,1);
H_2 = rand(L,1);
%% Definition of variables 
N=1000; %Frame length/ DFT size. N must be even
fs = 20e3; %sample freq
Nq = 2; %QAM modulation size
prefix_value = 100+1;
Lt = 10;% number of training
trainingFramesNum = Lt;%should be longer than the impulse response  frames 
H_1_omega = fft(H_1,N);
H_2_omega = fft(H_2,N);
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
[ofdmStream,trainpacket,lenDataPackage] = ofdm_mod_stereo(qamStream,N,true,prefix_value,remainder,trainblock,Lt,H_1_omega,H_2_omega);
ofdmStream_b = ofdmStream(:,1);
ofdmStream_a = ofdmStream(:,2);

%% CHannel modelization 
rxOfdmStream_a = filter(H_1,1,ofdmStream_a);
rxOfdmStream_b = filter(H_2,1,ofdmStream_b);

