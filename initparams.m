function [ simin,nbsecs,fs ] = initparams( toplay,fs_in )
%INITPARAMS
two_sec_silence=zeros(2*fs_in,1); %zero-vector with two seconds length
one_sec_silence=zeros(fs_in,1); %zero-vector with one second length
toplay=detrend(toplay); %removes (if existent) DC component of toplay
toplay=toplay/max(toplay); %scales the signal to [-1,1]
simin=[two_sec_silence two_sec_silence; toplay.' toplay.'; one_sec_silence one_sec_silence];
nbsecs=ceil((size(simin,1)/fs_in)); %calculates nr of seconds the signal is playing
fs=fs_in;
end

