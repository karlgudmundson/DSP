function [pnk] = compute_pnk(N)
%Function that computes noise power Pnk based on N samples 
disp('Please turn the volume off. Press a Key to go on')
pause;
fs = 36e3;
DFTsize = N;
t_end = 2;

%%%%%%%%%%%%%%%%%% First exp W/O sound %%%%%%%%%%%%%%%%%%%%%%
t = linspace(0,2,fs*t_end);
toplay = rand(length(t),1).';
[simin,nbsecs,fs] = initparams(toplay,fs);
options = simset('SrcWorkspace','current');
sim('recplay',[],options)
sig = simout.signals.values;
c =16;
psdout=[pwelch(simin(:,1),128*c,120*c,N,16e3) pwelch(sig(:,1),128*c,120*c,N,16e3)];
pnk = pwelch(sig(:,1),128*c,120*c,N,16e3);

figure 
pwelch(sig(:,1),128*c,120*c,N,16e3);
title('output noise')
end



