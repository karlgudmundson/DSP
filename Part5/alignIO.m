function [ out_aligned ] = alignIO( out,pulse )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[acor,lag] = xcorr(out,pulse);

[~,I] = max(abs(acor));
t_acor = 0:length(acor)-1;
plot(t_acor,acor);
lagDiff = lag(I); %shift in samples

out_aligned = out(lagDiff+1+400+length(pulse)/2-20:end); %400 added zeros in initparams
                                                         %20 samples buffert
                                                         %Not 100% sure about this though

end

