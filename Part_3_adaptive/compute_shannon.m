function [C_channel] = compute_shannon()
%Function that computes the capacity of the accoustic channel
% THIS FUNCTION REQUIRES initparams.m and recplay to work properly 
disp('Please turn the volume off. Press a Key to go on')
pause;
fs = 36e3;
DFTsize = 2048;
N = DFTsize/2;
t_end = 2;

%%%%%%%%%%%%%%%%%% First exp W/O sound %%%%%%%%%%%%%%%%%%%%%%
t = linspace(0,2,fs*t_end);
toplay = rand(length(t),1);
[simin,nbsecs,fs] = initparams(toplay,fs);
options = simset('SrcWorkspace','current');
sim('recplay',[],options)
sig = simout.signals.values;
c =16;
psdout=[pwelch(simin(:,1),128*c,120*c,128*c,16e3) pwelch(sig(:,1),128*c,120*c,128*c,16e3)];
pnk = psdout(:,2);
disp('Please turn the volume on. Press a Key to go on')
pause;

%%%%%%%%%%%%%%%%%%%%%% Second exp WITH sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = simset('SrcWorkspace','current');
sim('recplay',[],options)
sig = simout.signals.values;
c =16;
psdout=[pwelch(simin(:,1),128*c,120*c,128*c,16e3) pwelch(sig(:,1),128*c,120*c,128*c,16e3)];
psk = psdout(:,2) - pnk; %% subtracting noise from signal + noise if we assume that noise is stationary
vec = log2(1+psk./pnk);
C_channel = fs/DFTsize *sum(vec);
end

