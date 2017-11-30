<<<<<<< Updated upstream
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

=======
function [out_aligned, out_aligned_1] = alignIO(out,pulse)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%% MODIFY THIS VALUE IF NECESSARY :
fs = 16e3;
silence_duration = 2;
lengthIR = 400;
lengPulse = 2000;
margin = 20;
removeSamples = lengPulse+ lengthIR + silence_duration*fs - margin;

% Step 1: Cross Correlation
[r, lag] = xcorr(pulse,out);
% Step 2: Peak Detection
[~,peakLocation] = max(r);
% Step 3: Locate the delay
lagSig = lag(peakLocation);
out_aligned_1 = out(-lagSig:end);
% Step 4: remove silence and pulse 
out_aligned = out_aligned_1(removeSamples:end);


end

>>>>>>> Stashed changes
