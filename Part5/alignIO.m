function [ out_aligned ] = alignIO( out,pulse )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fs=16e3;

[acor,lag] = xcorr(out,pulse);

[~,I] = max(abs(acor));
lagDiff = lag(I); %shift in samples

out_aligned = out(lagDiff+1+380:end); %+380 because of 400 added zeros in initparams
                                      %Not 100% sure about this though

end

