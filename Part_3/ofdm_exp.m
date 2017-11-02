%x_clear all;
Nq = 6;
M = 2^Nq;
L = 100000; %%% length of randome sequence
rand_seq = randi([0, 1], L*log2(M),1);
mapping = 'bin';
UnitAveragePower = true;
N=6;
%%%%%%%%%%%% Transmitter TX %%%%%%%%%%%%%%
mod_vec = qam_mod_2(Nq,rand_seq,mapping,UnitAveragePower);
%% Transmitter TX
[x_serial] = ofdm_mod(mod_vec,N);

%% channel (ideal channel so far w/o noise and H(z) =1)

%% Receiver RX
x_mod = ofdm_demod(x_serial,N);

demod_x = qam_demod(x_mod,Nq,mapping,UnitAveragePower);

ber = ber(rand_seq,demod_x)
