function [ out_aligned ] = alignIO( out,pulse,fs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[acor,lag] = xcorr(out,pulse);

[~,I] = max(abs(acor));
t_acor = 0:length(acor)-1;
plot(t_acor,acor);
lagDiff = lag(I); %shift in samples

out_aligned = out(lagDiff+1+400+length(pulse)-70:end); %400 added zeros in initparams
                                                         %20 samples buffert
figure
plot(out_aligned)   %Not 100% sure about this though
hold on
plot(out)% 16000 is the
                                                         % remaining last
                                                         % second 

end

