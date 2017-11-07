clear all;
%function [demod_vec] = qam_experiment()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Nq = 6;
M = 2^Nq;
L = 100000; %%% length of randome sequence
rand_seq = randi([0, 1], L*log2(M),1);
mapping = 'bin';
UnitAveragePower = true;
SNR = 2000;
N = 12;
%%%%%%%%%%%% Transmitter TX %%%%%%%%%%%%%%
mod_vec = qam_mod_2(Nq,rand_seq,mapping,UnitAveragePower);
[x_serial] = ofdm_mod(mod_vec,N,'prefix',false);
%%%%%%%%%%% Channel -> AWGN %%%%%%%%%%%%%
%noisy_mod_vec = awgn(mod_vec, SNR);
%scatterplot(noisy_mod_vec);
noisy_x_serial = x_serial;
%%%%%%%%%%% Receiver RX %%%%%%%%%%%%%
[Y] = ofdm_demod(noisy_x_serial,N,'prefix',false,L)
demod_vec = qam_demod(Y,Nq,mapping,UnitAveragePower);
%%%%%%%%%% BIT ERROR RATE COMPUTATION %%%%%%%%%%%%%
[ber] = ber(rand_seq,demod_vec)
%end


