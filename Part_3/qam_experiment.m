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
SNR = 20;
%%%%%%%%%%%% Transmitter TX %%%%%%%%%%%%%%
mod_vec = qam_mod_2(Nq,rand_seq,mapping,UnitAveragePower);
%%%%%%%%%%% Channel -> AWGN %%%%%%%%%%%%%
noisy_mod_vec = awgn(mod_vec, SNR);
scatterplot(noisy_mod_vec);
%%%%%%%%%%% Receiver RX %%%%%%%%%%%%%
demod_vec = qam_demod(noisy_mod_vec,Nq,mapping,UnitAveragePower);
%%%%%%%%%% BIT ERROR RATE COMPUTATION %%%%%%%%%%%%%
[ber] = ber(rand_seq,demod_vec)
%end


