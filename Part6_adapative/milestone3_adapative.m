clear all;
tic
%% Definition of variables 
N=2000; %Frame length/ DFT size. N must be even
fs = 25e3; %sample freq
Nq = 4; %QAM modulation size
SNR=20; %Signal to noise ratio
L=10; %channel order
prefix_value = 400+1;
trainingFramesNum = 40;%should be longer than the impulse response
Lt = 15; % number of training frames 
Ld = 30; % number of data frames
gamma = 1.1;
N_kept = N/2 -1;
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%% Channel estimation
for k =1:1:2
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
    
   %%% Noise measurmenent
    if (k ==2)
    Rx_noise_measurement = filter(ifft(IR_freq_est_old),1,Rx_old);
    noise_recorded_vec = Rx -Rx_noise_measurement;
    end
    IR_freq_est_old = IR_freq_est;
    Rx_old = Rx;
end
pnk = pwelch(noise_recorded_vec,128,120,N-1,16e3);
bk = compute_bk(IR_freq_est(2:N/2),gamma,pnk(2:end));
%% qamstream generation
% QAM modulation
[qamStream,m,bits_remainding,quotient,bk_generalized] = qam_mod_adaptive(bk,bitStream,'bin',true);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));
%% Trainig part 
trainingFramesNum = Lt; %% number of training frames 
trainblock=randi([0 1], (N/2-1)*Nq, 1);
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,trainingFramesNum,1);
%% OFDM Modulation 
%ofdmStream_on_off = ofdm_mod(qamStream,N,true,prefix_value,remainder);
%ofdmStream_on_off = ofdm_mod_on_off(qamStream,N,true,prefix_value,remainder_on_off,new_index_array);
[ofdmStream,trainpacket,div_Ld,Mod_Ld] = ofdm_mod_training(qamStream,N,true,prefix_value,remainder,trainblock,Lt,Ld);

%% Real channel  
%ofdmStream_on_off = ofdmStream_on_off./max(abs(ofdmStream_on_off));
%ofdmStream_on_off = ofdmStream_on_off.*max(abs(Tx));
t=0:1/fs:1000/fs;
pulse=(1).*sin(2*pi*800*t); %short sine function is a good pulse
%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(ofdmStream,fs,pulse); %Calls for function initparams.m
sim('recplay2');
out=simout.signals.values;
%% Signal Alignment 
Rx = alignIO(out(:,1), pulse,fs);
Rx = Rx(1:length(ofdmStream),1);
%% OFDM demodulation + equalization
%rxQamStream_on_off = ofdm_demod(Rx,N,true,prefix_value,remainder,IR_freq_est);
%rxQamStream_on_off = ofdm_demod_on_off(Rx,N,true,prefix_value,remainder_on_off,IR_freq_est,new_index_array);
[rxQamStream,H_k] = ofdm_demod_training(Rx,N,true,prefix_value,remainder,trainpacket,Lt,Ld,div_Ld,Mod_Ld);
rxBitStream = qam_demod_adaptive(rxQamStream,bk_generalized,'bin',true,bits_remainding,quotient,m);
%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
toc