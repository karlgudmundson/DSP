function [Y] = ofdm_demod(noisy_x_serial,N,pre,L,rem)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Serial to parallel conversion and removing prefixs
if (pre == true)    
    noisy_x = reshape(noisy_x_serial,(N+L),[]);
    noisy_x = noisy_x(L+1:end,:);
else 
    noisy_x = reshape(noisy_x_serial,(N),[]);
end

%% OFDM demodulation process
X = zeros(size(noisy_x));

for k = 1:1:size(noisy_x,2)
    X(:,k) = (1./N)*fft(noisy_x(:,k),N);
end

%% in the simplest case, the only required operation is the extraction of X_k coefficients
% Be careful there's some redundancy wihtin the X matrix (see slides lecture 3) 
Y = X(2:(N/2),:);
Y = reshape(Y,[],1);

%% Remove zeros from last package if needed
if (rem ~= 0)
    Y=Y(1:end-((N/2-1)-rem));
end

