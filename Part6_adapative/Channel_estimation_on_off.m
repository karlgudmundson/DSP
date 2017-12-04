function [simin,nbsecs,fs,remainder,trainblock,pulse] = Channel_estimation_on_off(fs,N,Nq,trainingFramesNum)
prefix_value = 401; %should be longer than the impulse response
trainblock=randi([0 1], (N/2-1)*Nq, 1);
bitStream =repmat(trainblock,trainingFramesNum,1);
% such that you can be sure that you have a N/2 -1 qam sequence by
% modulating this bitstream 
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1); %repeating the vector trainingFramesNum times

%%%% OFDM modulation %%%%%%
remainder = mod(length(trainblock),(N/2 -1)); % a pripori not required 
Tx=ofdm_mod(trainblock,N,true,prefix_value,remainder); %ofdm modulation

%%% Real channel %%%
t=0:1/fs:1000/fs;
pulse=1*sin(2*pi*800*t); %short sine function is a good pulse
%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(Tx,fs,pulse); %Calls for function initparams.m

sim('recplay2');
out=simout.signals.values;
Rx = alignIO(out, pulse,fs);
Rx = Rx(1:length(Tx),1);
%%%% OFDM Demodulation %%%%%%
trainblock = reshape(trainblock,N/2-1,[]);
trainblock_star = conj(trainblock);
trainblock = [zeros(1,size(trainblock,2)); trainblock ; zeros(1,size(trainblock,2)) ; flipud(trainblock_star)];
[Rx_demod,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainder,trainblock);
rxBitStream = qam_demod(Rx_demod,Nq,'bin',true);

%%% BER computation %%%
[berTransmission] = ber(bitStream,rxBitStream);
end

