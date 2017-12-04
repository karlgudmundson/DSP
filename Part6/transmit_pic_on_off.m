clear all;
close all;
tic
load('IRest.mat')
channel_IR = h;
%% Definition of variables 
N=500; %Frame length/ DFT size. N must be even
eq = fft(h,N);
fs = 24e3; %sample freq
Nq = 3; %QAM modulation size
SNR=20; %Signal to noise ratio
L=10; %channel order
prefix_value = length(h)+1;
trainingFramesNum = 80;%should be longer than the impulse response
Lt = 20; % number of training frames 
Ld = 20; % number of data frames
BWusage = 40;
N_kept = floor((BWusage./100)*(N./2 -1));%For ON-OFF bit loading 


%% Channel estimation
trainblock=randi([0 1], (N/2-1)*Nq, 1);
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
pulse=1*sin(2*pi*800*t); %short sine function is a good pulse
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
[Rx_demod,IR_freq_est] = ofdm_demod_channel_est(Rx,N,true,prefix_value,remainderEst,trainblock);
rxBitStreamEst = qam_demod(Rx_demod,Nq,'bin',true);

%%% BER computation %%%
[berTransmissionEst] = ber(bitStreamEst,rxBitStreamEst); 
%% qamstream generation
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));
%% Trainig part 
[sorted_arry,index_array] = sort(abs(IR_freq_est(1:N/2)),'descend');
new_index_array = index_array(1:N_kept);
new_index_array = sort(new_index_array,'ascend');
remainder_on_off = mod(length(qamStream),(N_kept));
%% OFDM Modulation 
ofdmStream_on_off = ofdm_mod_on_off(qamStream,N,true,prefix_value,remainder_on_off,new_index_array); 
%%
%%% Real channel %%%

t=0:1/fs:1000/fs;
pulse=(0.8).*sin(2*pi*800*t); %short sine function is a good pulse

%%%RECORDING AND PLAYING%%%
[simin,nbsecs,~]=initparams_5(ofdmStream_on_off,fs,pulse); %Calls for function initparams.m
sim('recplay2');
out=simout.signals.values;
%%
Rx = alignIO(out(:,1), pulse,fs);
Rx = Rx(1:length(ofdmStream_on_off),1);
% % Channel with true impulse response
% rxOfdmStream = filter(h,1,ofdmStream);
% % Adding white noise
% Rx = awgn(rxOfdmStream, SNR, 'measured'); %%%% ALWAYS ADD 'measured'
%% OFDM demodulation + equalization
rxQamStream_on_off = ofdm_demod_on_off(Rx,N,true,prefix_value,remainder_on_off,IR_freq_est,new_index_array);
% QAM demodulation
rxBitStream = qam_demod(rxQamStream_on_off,Nq,'bin',true);

%% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

toc