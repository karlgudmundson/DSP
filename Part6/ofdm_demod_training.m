function [Y,H_k] = ofdm_demod_training(noisy_x_serial,N,pre,L,rem,trainblock,Lt,ld)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Serial to parallel conversion and removing prefixs
if (pre == true)    
    noisy_x = reshape(noisy_x_serial,(N+L),[]);
    noisy_x = noisy_x(L+1:end,:);
else 
    noisy_x = reshape(noisy_x_serial,(N),[]);
end


%% Channel estimation
X = zeros(size(noisy_x));

for k = 1:1:size(noisy_x,2)
    X(:,k) = (1./N)*fft(noisy_x(:,k),N);
end

H_k = zeros(size(X,1),1);
for l =1:1:size(X,1)
    Y_received_k = X(l,:);
    X_sent_k = trainblock(l,:);
    Y_received_k = Y_received_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
    X_sent_k = X_sent_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
    H_k(l) = X_sent_k\Y_received_k; %% least square estimation 
end
%% OFDM demodulation process USING the channel frequency estimate
X = zeros(size(noisy_x));

for k = 1:1:size(noisy_x,2)
    X(:,k) = (1./N)*fft(noisy_x(:,k),N)./H_k;
end

%% in the simplest case, the only required operation is the extraction of X_k coefficients
% Be careful there's some redundancy wihtin the X matrix (see slides lecture 3) 
Y = X(2:(N/2),:);
Y = reshape(Y,[],1);

%% Remove zeros from last package if needed
if (rem ~= 0)
    Y=Y(1:end-((N/2-1)-rem));
end



