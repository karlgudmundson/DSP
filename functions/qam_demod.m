function [demod_vec] = qam_demod(noisy_mod_vec,Nq,mapping,UnitAveragePower)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
M = 2^Nq;
demod_vec = qamdemod(noisy_mod_vec, M, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', true);

end

