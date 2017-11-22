function [mod_vec_tot,m,bits_remainding,quotient,bk_generalized] = qam_mod_adaptive(bk,sequence,mapping,UnitAveragePower)
%This function create a QAM modulation of the input sequence with several
%arguments such as the mapping, the QAM order, ... notice that mapping can
%be either 'gray' or 'bin' and UniAveragPozer can be either true or false

% sum(bk) represents the number of bits that you can modulate per frame
remainder = rem(length(sequence),sum(bk));
quotient = floor(length(sequence)/sum(bk)); %% number of frame required in the OFDM

M = (quotient+1)*length(bk); %% length of total modulated vector 
m = 1; %% is the index of bk where all bits are modulated
while (sum(bk(1:m)) < remainder ) m=m+1;end
bits_remainding = rem(remainder,sum(bk(1:m-1)));
bk_last = bk;
bk_last(m) = bits_remainding;
bk_last(m+1:end) = 0;
bk_generalized = repmat(bk,quotient,1);
bk_generalized = [bk_generalized ; bk_last];

last_index = [1 1 1 1 1 1 1];
for k =1:1:length(bk_generalized)
     Mk = bk_generalized(k);
     seq_k = sequence(1:Mk);
     sequence = sequence(Mk+1:end);
    switch Mk
        case 0
            modulated_vec_0(last_index(1):last_index(1)) =0;
            last_index(1)=last_index(1)+1;
        case 1 
            mod_vec_1(last_index(2):last_index(2)) = seq_k;
            last_index(2) = last_index(2)+1;
        case 2
            mod_vec_2(last_index(3):last_index(3)+1) = seq_k;
            last_index(3) = last_index(3)+2;
        case 3
            mod_vec_3(last_index(4):last_index(4)+2) = seq_k;
            last_index(4) = last_index(4)+3;
        case 4
            mod_vec_4(last_index(5):last_index(5)+3) = seq_k;
            last_index(5) = last_index(5)+4;
        case 5
            mod_vec_5(last_index(6):last_index(6)+4) = seq_k;
            last_index(6) = last_index(6)+5;
        case 6
            mod_vec_6(last_index(7):last_index(7)+5) = seq_k;
            last_index(7) = last_index(7)+6;
    end
           
end

modulated_vec_1 = qammod(mod_vec_1', 2,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
modulated_vec_2 = qammod(mod_vec_2', 4,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
modulated_vec_3 = qammod(mod_vec_3', 8, mapping,'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
modulated_vec_4 = qammod(mod_vec_4', 16,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
modulated_vec_5 = qammod(mod_vec_5', 32,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
modulated_vec_6 = qammod(mod_vec_6', 64,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);

mod_vec_tot = zeros(length(bk_generalized),1); 

index_6 = bk_generalized ==6;
index_5 = bk_generalized ==5;
index_4 = bk_generalized ==4;
index_3 = bk_generalized ==3;
index_2 = bk_generalized ==2;
index_1 = bk_generalized ==1;
index_0 = bk_generalized ==0;

mod_vec_tot(index_0) = modulated_vec_0;
mod_vec_tot(index_1) = modulated_vec_1;
mod_vec_tot(index_2) = modulated_vec_2;
mod_vec_tot(index_3) = modulated_vec_3;
mod_vec_tot(index_4) = modulated_vec_4;
mod_vec_tot(index_5) = modulated_vec_5;
mod_vec_tot(index_6) = modulated_vec_6;
end



