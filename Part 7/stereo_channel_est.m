clear all;
close all;
warning off;
%% Definition of variables
N=1000; %Frame length/ DFT size. N must be even
fs = 20e3; %sample freq
Nq = 4; %QAM modulation size
prefix_value = 400+1;
Lt = 40;% number of training
trainingFramesNum = Lt;%should be longer than the impulse response  frames
numOfLoudSpeaker = 2;
H_tot = ones(N,2);
berTransmissionEst = ones(2,1);
%% qamstream generation
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
trainblock=bitStream(1:(N/2-1)*Nq);
%trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=repmat(trainblock,trainingFramesNum,1); %repeating the vector trainingFramesNum times
bitStreamEst = trainblock;
speaker_index = ['a', 'b'];
trainblock=qam_mod_2(Nq,trainblock,'bin',true);
for k = 1:1:numOfLoudSpeaker
    %%%% OFDM modulation %%%%%%
    remainderEst = mod(length(trainblock),(N/2 -1)); % a pripori not required
    Tx=ofdm_mod(trainblock,N,true,prefix_value,remainderEst); %ofdm modulation
    Tx = [Tx, Tx];
    %%% Real channel %%%
    t=0:1/fs:1000/fs;
    pulse=(0.8).*sin(2*pi*800*t); %short sine function is a good pulse
    %%%RECORDING AND PLAYING%%%
    
    [simin,nbsecs,~]=initparams_stereo(Tx,fs,pulse,speaker_index(k)); %Calls for function initparams.m
    
    sim('recplay2');
    out=simout.signals.values;
    Rx = alignIO7(out(:,1), pulse,fs);
    Rx = Rx(1:length(Tx),1);
    %%%% OFDM Demodulation %%%%%%
    trainblock2 = reshape(trainblock,N/2-1,[]);
    trainblock_star = conj(trainblock2);
    trainblock2 = [zeros(1,size(trainblock2,2)); trainblock2 ; zeros(1,size(trainblock2,2)) ; flipud(trainblock_star)];
    [ty,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainderEst,trainblock2);
    Rx_demod = ofdm_demod(Rx,N,true,prefix_value,remainderEst,IR_freq_est);
    rxBitStreamEst = qam_demod(Rx_demod,Nq,'bin',true);
    H_tot(:,k) = IR_freq_est;
    %%% BER computation %%%
    berTransmissionEst(k) = ber(bitStreamEst,rxBitStreamEst);
end
figure
fourier_sig_right = mag2db(abs(H_tot(:,1)));
fourier_sig_left = mag2db(abs(H_tot(:,2)));
plot(fourier_sig_right)
title('H_1 (right loudspeaker)');
figure
plot(fourier_sig_left)
title('H_2 (left loudspeaker)');
