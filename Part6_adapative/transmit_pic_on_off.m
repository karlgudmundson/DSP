clear all;
tic
%% Definition of variables 
N=2000; %Frame length/ DFT size. N must be even
fs = 16e3; %sample freq
Nq = 4; %QAM modulation size
SNR=20; %Signal to noise ratio
L=10; %channel order
prefix_value = 400+1;
trainingFramesNum = 40;%should be longer than the impulse response
Lt = 10; % number of training frames 
Ld = 30; % number of data frames
BWusage = 30;
N_kept = floor((BWusage./100)*(N./2 -1));%For ON-OFF bit loading 
%% qamstream generation
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));

%% Channel estimation
%trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=bitStream(1:(N/2-1)*Nq, 1);
bitStreamEst =repmat(trainblock,trainingFramesNum,1);
% such that you can be sure that you have a N/2 -1 qam sequence by
% modulating this bitstream 
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1); %repeating the vector trainingFramesNum times

%%%% OFDM modulation %%%%%%
remainderEst = mod(length(trainblock),(N/2 -1)); % a pripori not required 
Tx=ofdm_mod(trainblock,N,true,prefix_value,remainderEst); %ofdm modulation

%%% Real channel %%%
t=0:1/fs:1000/fs;
pulse=(0.8).*sin(2*pi*800*t); %short sine function is a good pulse
%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(Tx,fs,pulse); %Calls for function initparams.m

sim('recplay2');
out=simout.signals.values;
Rx = alignIO(out(:,1), pulse,fs);
Rx = Rx(1:length(Tx),1);
%%%% OFDM Demodulation %%%%%%
trainblock = reshape(trainblock,N/2-1,[]);
trainblock_star = conj(trainblock);
trainblock = [zeros(1,size(trainblock,2)); trainblock ; zeros(1,size(trainblock,2)) ; flipud(trainblock_star)];
[ty,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainderEst,trainblock);
Rx_demod = ofdm_demod(Rx,N,true,prefix_value,remainderEst,IR_freq_est);
rxBitStreamEst = qam_demod(Rx_demod,Nq,'bin',true);

%%% BER computation %%%
[berTransmissionEst] = ber(bitStreamEst,rxBitStreamEst); 

%% Trainig part 
[sorted_arry,index_array] = sort(abs(IR_freq_est(2:N/2)),'descend');
new_index_array = index_array(1:N_kept);
new_index_array = sort(new_index_array,'ascend');
remainder_on_off = mod(length(qamStream),(N_kept));

trainingFramesNum = Lt; %% number of training frames 
trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1);
%% OFDM Modulation 
%ofdmStream_on_off = ofdm_mod(qamStream,N,true,prefix_value,remainder);
%ofdmStream_on_off = ofdm_mod_on_off(qamStream,N,true,prefix_value,remainder_on_off,new_index_array);
[ofdmStream_on_off,trainpacket,div_Ld,Mod_Ld] = ofdm_mod_training_on_off(qamStream,N,true,prefix_value,remainder_on_off,trainblock,Lt,Ld,new_index_array);

%% Real channel  
%ofdmStream_on_off = ofdmStream_on_off./max(abs(ofdmStream_on_off));
%ofdmStream_on_off = ofdmStream_on_off.*max(abs(Tx));
t=0:1/fs:1000/fs;
pulse=(1).*sin(2*pi*800*t); %short sine function is a good pulse
%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(ofdmStream_on_off,fs,pulse); %Calls for function initparams.m
sim('recplay2');
out=simout.signals.values;
%% Signal Alignment 
Rx = alignIO(out(:,1), pulse,fs);
Rx = Rx(1:length(ofdmStream_on_off),1);
%% OFDM demodulation + equalization
%rxQamStream_on_off = ofdm_demod(Rx,N,true,prefix_value,remainder,IR_freq_est);
%rxQamStream_on_off = ofdm_demod_on_off(Rx,N,true,prefix_value,remainder_on_off,IR_freq_est,new_index_array);
[rxQamStream_on_off,H_k] = ofdm_demod_training_on_off(Rx,N,true,prefix_value,remainder_on_off,trainpacket,Lt,Ld,div_Ld,Mod_Ld,new_index_array);
rxBitStream = qam_demod(rxQamStream_on_off,Nq,'bin',true);% QAM demodulation
%% Data visualisation 
visualize_demod_on_off(H_k,N,fs,imageData,colorMap,Ld,Lt,prefix_value,rxBitStream,Nq,N_kept,new_index_array);
%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);
toc