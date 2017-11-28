function [ out_aligned ] = alignIO( out,pulse )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[acor,lag] = xcorr(out,pulse);

[~,I] = max(abs(acor));
lagDiff = lag(I); %shift in samples

out_aligned = out(-lagDiff+1:end);

end

