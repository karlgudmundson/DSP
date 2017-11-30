function [ simin,nbsecs,fs ] = initparams( toplay,fs_in )
%INITPARAMS 1.00 (9/10/2017)
% Updated version for 5.2  1.01 (23/11/2017)
lengthIR = zeros(400,1);
pulseSig = [zeros(500,1);ones(1000,1) ;zeros(500,1)]; %% pulseSig is a square signal
two_sec_silence=zeros(2*fs_in,1); %zero-vector with two seconds length
one_sec_silence=zeros(fs_in,1); %zero-vector with one second length
toplay=detrend(toplay); %removes (if existent) DC component of toplay
toplay=toplay/max(toplay); %scales the signal to [-1,1]
simin=[two_sec_silence two_sec_silence;pulseSig pulseSig ;lengthIR  lengthIR; toplay.' toplay.'; one_sec_silence one_sec_silence];
nbsecs=ceil((size(simin,1)/fs_in)); %calculates nr of seconds the signal is playing
fs=fs_in;
end

