function [IR_freq_est,berTransmission] = Channel_estimation_on_off_next(Rx,N,true,prefix_value,remainder,trainblock)
%%%% OFDM Demodulation %%%%%%
trainblock = reshape(trainblock,N/2-1,[]);
trainblock_star = conj(trainblock);
trainblock = [zeros(1,size(trainblock,2)); trainblock ; zeros(1,size(trainblock,2)) ; flipud(trainblock_star)];
[Rx_demod,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainder,trainblock);
rxBitStream = qam_demod(Rx_demod,Nq,'bin',true);

%%% BER computation %%%
[berTransmission] = ber(bitStream,rxBitStream);
end


