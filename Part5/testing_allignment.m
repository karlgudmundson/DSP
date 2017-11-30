clear all;
fs = 16e3;
t_end = 2;
t = linspace(0,2,fs*t_end);
toplay = 0.5*sin(2*pi*440.*t);
[simin,nbsecs,fs] = initparams(toplay,fs);
options = simset('SrcWorkspace','current');
sim('recplay2',[],options)
sig = simout.signals.values;

figure
plot(simin)
hold on 
plot(sig)
title('unsynchronized signals')
%%%
[out_aligned, out_aligned_1] = alignIO(sig(:,1),simin(:,1));
%%%
figure 
plot(simin)
hold on 
plot(out_aligned_1)
title('synchronized signals')
%%%
figure
plot(out_aligned)