function [h] = IR2()
%This function computes the IR bqsed on the second method (Toeplitz matrix)

%%%%%%%%%% Playing and recoring a white noise signal %%%%%%%%%%%%%%%%%%%
fs = 16e3;
t_end = 2;
t = linspace(0,2,fs*t_end);
toplay = rand(length(t),1).';
[simin,nbsecs,fs] = initparams(toplay,fs);
options = simset('SrcWorkspace','current');
sim('recplay',[],options)
sig = simout.signals.values;
figure
subplot(2,1,1)
plot(simin(20e3:end,1));
title('Played samples')
xlabel('samples [n]');
ylabel('amplitude');
grid on
subplot(2,1,2)
plot(sig(20e3:end,1))
title('Recorded samples');
xlabel('samples [n]');
ylabel('amplitude');
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% DELAY ??? %%%%%%%%%%%%%%%
u = simin(32001:64000)';
y = sig(35450:35450+32e3-1)';
u_row = zeros(1,400);
u_row(1) = u(1);
A = toeplitz(u,u_row);
h = lsqr(A,y');
save('IRest.mat','h')

fourier_sig = fftshift(fft(h)) %%% define the DFT size 


figure
subplot(2,1,1)
plot(h)
title('IR2 in time domain (2nd method)')
xlabel('samples [n]');
ylabel('amplitude');
grid on
subplot(2,1,2)
k = 0:1:length(h)-1;
f_axis = fs*k/length(h) -fs/2;
fourier_sig = mag2db(abs(fourier_sig));
plot(f_axis,fourier_sig);
title('DFT of IR2 (2nd method)');
xlabel('frequency [Hz]');
ylabel('Magnitude [dB]');
grid on

c= 16;
psdout=[pwelch(simin(:,1),128*c,120*c,128*c,16e3) pwelch(sig(:,1),128*c,120*c,128*c,16e3)];
figure
subplot(2,1,1)
pwelch(simin(:,1),128*c,120*c,128*c,16e3); %% wind, overlaps, DFTsize,fs
title('Power Spectral Density of transmitted signal')
subplot(2,1,2)
pwelch(sig(:,1),128*c,120*c,128*c,16e3);
title('Power Spectral Density of recorded signal')

end

