function [demod_vec_tot] = qam_demod_adaptive(noisy_mod_vec,bk_generalized,mapping,UnitAveragePower,bits_remainding,quotient,m)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%
index_6 = bk_generalized ==6;
index_5 = bk_generalized ==5;
index_4 = bk_generalized ==4;
index_3 = bk_generalized ==3;
index_2 = bk_generalized ==2;
index_1 = bk_generalized ==1;

modulated_vec_1 = noisy_mod_vec(index_1);
modulated_vec_2 = noisy_mod_vec(index_2);
modulated_vec_3 = noisy_mod_vec(index_3);
modulated_vec_4 = noisy_mod_vec(index_4);
modulated_vec_5 = noisy_mod_vec(index_5);
modulated_vec_6 = noisy_mod_vec(index_6);

demod_vec_1 = qamdemod(modulated_vec_1 , 2, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_2 = qamdemod(modulated_vec_2 , 4, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_3 = qamdemod(modulated_vec_3 , 8, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_4 = qamdemod(modulated_vec_4 , 16, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_5 = qamdemod(modulated_vec_5 , 32, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_6 = qamdemod(modulated_vec_6 , 64, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
demod_vec_tot = [];
last_index = [1 1 1 1 1 1 1];
for k =1:1:length(bk_generalized)
     Mk = bk_generalized(k);
    switch Mk
        case 0
            demod_elem = [];
        case 1 
            demod_elem = demod_vec_1(last_index(2):last_index(2));
            last_index(2) = last_index(2)+1;
        case 2
            demod_elem = demod_vec_2(last_index(3):last_index(3)+1);
            last_index(3) = last_index(3)+2;
        case 3
            demod_elem = demod_vec_3(last_index(4):last_index(4)+2);
            last_index(4) = last_index(4)+3;
        case 4
            demod_elem = demod_vec_4(last_index(5):last_index(5)+3);
            last_index(5) = last_index(5)+4;
        case 5
            demod_elem = demod_vec_5(last_index(6):last_index(6)+4);
            last_index(6) = last_index(6)+5;
        case 6
            demod_elem = demod_vec_6(last_index(7):last_index(7)+5);
            last_index(7) = last_index(7)+6;
    end
    demod_vec_tot = [demod_vec_tot ;demod_elem];        
end























% %% demodulation of all frames except last one
% demod_vec_tot = [];
% for k =1:1:quotient
%     for l =1:1:length(bk)
%         Mk = bk(l);
%         if Mk ~= 0
%             demod_vec = qamdemod(noisy_mod_vec((k-1)*length(bk) + l), 2^Mk, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
%         else
%             demod_vec = [];
%         end
%         demod_vec_tot = [demod_vec_tot; demod_vec];
%     end
%       
%     
% end
% 
% %% for last frame 
% bk(m) = bits_remainding;
% for l =1:1:m
%     Mk = bk(l);
%     if Mk ~= 0
%         demod_vec = qamdemod(noisy_mod_vec((quotient)*length(bk) + l), 2^Mk, mapping, 'OutputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', false);
%     else
%         demod_vec = [];
%     end
%     demod_vec_tot = [demod_vec_tot; demod_vec];
% end


end



