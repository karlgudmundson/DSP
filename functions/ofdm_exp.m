clear all;
rand_seq = [1 1 0 1 0 0 0 1 0 1 1 1 0 1 0 0 0 1 0 1];
%%% Here let's assume a 4qam modulation
mod_vec = [1-1*1i, -1-1*1i, -1+1*1i, -1-1*1i, -1-1*1i,1-1*1i, -1-1*1i, -1+1*1i, -1-1*1i, -1-1*1i];
N = 12;
%% Transmitter TX
[x_serial] = ofdm_mod(mod_vec,N,'prefix',false);

%% channel (ideal channel so far w/o noise and H(z) =1)
noisy_x_serial = x_serial;

%% Receiver RX
[Y] = ofdm_demod(noisy_x_serial,N);
