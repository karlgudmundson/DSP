function [ dataMod ] = qam_mod( bin_seq )
%QAM_MOD

M=64;
k=6;
dataInMatrix = reshape(bin_seq,length(bin_seq)/k,k);
dataSymbolsIn = bi2de(dataInMatrix);
dataMod = qammod(dataSymbolsIn,M,'bin');

end

