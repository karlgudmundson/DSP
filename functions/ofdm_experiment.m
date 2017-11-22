clear all;
close all;
%function [demod_vec] = qam_experiment()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Nq = 4;
M = 2^Nq;
L = 100; %%% length of random sequence
rand_seq = randi([0, 1], L*log2(M),1);
mapping = 'bin';
UnitAveragePower = true;
SNR = 20;
N = 26;
prefix_value = 9;
%%%%%%%%%%%% Transmitter TX %%%%%%%%%%%%%%
mod_vec = qam_mod_2(Nq,rand_seq,mapping,UnitAveragePower);
%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(mod_vec),(N/2 -1));
%%%%%%%%%%% Channel -> AWGN %%%%%%%%%%%%%
mod_vec = awgn(mod_vec, SNR);
scatterplot(mod_vec);
[x_serial] = ofdm_mod(mod_vec,N,true,prefix_value,remainder);
noisy_x_serial = x_serial;
%%%%%%%%%%% Receiver RX %%%%%%%%%%%%%
[Y] = ofdm_demod(noisy_x_serial,N,true,prefix_value,remainder);
demod_vec = qam_demod(Y,Nq,mapping,UnitAveragePower);
%%%%%%%%%% BIT ERROR RATE COMPUTATION %%%%%%%%%%%%%
[berTransmission] = ber(rand_seq,demod_vec)
%end