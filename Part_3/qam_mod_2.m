function [mod_vec] = qam_mod_2(Nq,sequence,mapping,UnitAveragePower)
%This function create a QAM modulation of the input sequence with several
%arguments such as the mapping, the QAM order, ... notice that mapping can
%be either 'gray' or 'bin' and UnitAveragPower can be either true or false

%% truncating the #bits such that the modulation works proprely
trunc = mod(length(sequence),Nq);
sequence = sequence(1:end-trunc);

%% modulation 
M = 2^Nq;
mod_vec = qammod(sequence, M,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', true);

end

