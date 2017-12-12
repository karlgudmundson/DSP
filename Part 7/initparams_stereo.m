function [ simin,nbsecs,fs,toplay] = initparams_stereo( toplay,fs_in,pulse,speaker)
%INITPARAMS
two_sec_silence=zeros(2*fs_in,1); %zero-vector with two seconds length
one_sec_silence=zeros(fs_in,1); %zero-vector with one second length
%toplay=detrend(toplay); %removes (if existent) DC component of toplay
if (speaker == 'a') 
    toplay1=toplay(:,1);
    toplay2=toplay(:,2)/max(abs(toplay(:,2))); %scales the signal to [-1,1]
    simin=[two_sec_silence two_sec_silence; pulse.' pulse.'; zeros(400,1) zeros(400,1); toplay1, toplay2; one_sec_silence one_sec_silence];
    simin(:,1) = 0;
elseif (speaker == 'b')
    toplay2=toplay(:,2);
    toplay1=toplay(:,1)/max(abs(toplay(:,1))); %scales the signal to [-1,1]
    simin=[two_sec_silence two_sec_silence; pulse.' pulse.'; zeros(400,1) zeros(400,1); toplay1, toplay2; one_sec_silence one_sec_silence];
    simin(:,2) = 0;
else
    toplay2=toplay(:,2)/max(abs(toplay(:,2))); %scales the signal to [-1,1]
    toplay1=toplay(:,1)/max(abs(toplay(:,1))); %scales the signal to [-1,1]
    simin=[two_sec_silence two_sec_silence; pulse.' pulse.'; zeros(400,1) zeros(400,1); toplay1, toplay2; one_sec_silence one_sec_silence];
end
nbsecs=ceil((size(simin,1)/fs_in)); %calculates nr of seconds the signal is playing
fs=fs_in;
end