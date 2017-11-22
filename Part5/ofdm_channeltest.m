load('IRest.mat')
h=h_IR2;

%Constants
N = 1e3; %DFT size
Nq = 6; %QAM modulation size
prefix_value = length(h)+1; %should be longer than the impulse response
trainblock=randi([0 1], (N/2-1)*Nq, 1); %random bitstream
trainblock=qam_mod_2(Nq,trainblock,'bin',true); %qam modulation
trainblock=repmat(trainblock,100,1); %repeating the vector 100 times

remainder = mod(length(trainblock),(N/2 -1));
Tx=ofdm_mod(trainblock,N,false,prefix_value,remainder); %ofdm modulation

Rx = filter(h,1,Tx);


