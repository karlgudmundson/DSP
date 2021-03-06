function [Y,H_k_tot] = ofdm_demod7(noisy_x_serial,N,pre,L,rem,trainpacket,Lt,lenDataPackage,Nq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Serial to parallel conversion and removing prefixs
if (pre == true)    
    noisy_x = reshape(noisy_x_serial,(N+L),[]);
    noisy_x = noisy_x(L+1:end,:);
else 
    noisy_x = reshape(noisy_x_serial,(N),[]);
end


%% Channel estimation for NLMS initilisation
X = zeros(size(noisy_x));
for k = 1:1:Lt
    X(:,k) = (1./1)*fft(noisy_x(:,k),N);
end
X_training = X(:,1:Lt);

H_k = zeros(size(X_training,1),1); %% Only for initialising the NLMS 
for k = 1:1:size(X_training,1)
        Y_received_k = X_training(k,:);
        X_sent_k = trainpacket(k,:);
        Y_received_k = Y_received_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
        X_sent_k = X_sent_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
        H_k(k) = X_sent_k\Y_received_k; %% least square estimation
end
%% Demodulation of Data packages 
X = zeros(size(noisy_x));
for k = Lt+1:1:size(noisy_x,2)
    X(:,k) = (1./N)*fft(noisy_x(:,k),N);
end
Yk = X(:,Lt+1:end);
%% NLMS
Wk = zeros(lenDataPackage);
%X_k_tild = zeros(size(noisy_x));
Wk(:,1) = (1./H_k').'; %complex conjugate, should be without dot ;)
Wk(1,1) = 0 + j*0;
Wk(N/2 +1,1) = 0 + j*0;
mu = 2; %should be between 0 and 2 (for NLMS)
%lower my is more stable but converges slower
%my too high can give unstable Wk
alpha = 0.0; %avoid to divid by 0--> choosing 0.1 is ok but the smartest way of doing this is measuring the mean value of U*U' and taking a value that make sense

%%% Computation of Xk(L+1) = Yk(L+1)*Wk(L)'
%qammod(sequence, M,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', true);
for m=1:1:size(Yk,2)-1
    W_tild = Wk(:,m)';
    X_k_tild = (W_tild.').*Yk(:,m+1);
    X_k_hat = qammod(qamdemod(X_k_tild,2^Nq,'bin','OutputType', 'bit','UnitAveragePower', true),2^Nq,'bin','InputType', 'bit','UnitAveragePower', true);
    a_priori_error =  mu*Yk(:,m+1).*conj(X_k_hat-X_k_tild)./(alpha + Yk(:,m+1)'*Yk(:,m+1));
    Wk(:,m+1) = Wk(:,m) +   a_priori_error; %% What about alpha ?
end
X_out = ((Wk').').*Yk;
H_k_tot = (1./Wk').';
H_k_tot(1,:) = 0 + j*0;
H_k_tot(501,:) = 0 + j*0;
%% in the simplest case, the only required operation is the extraction of X_k coefficients
% Be careful there's some redundancy wihtin the X matrix (see slides lecture 3) 
Y = X_out(2:(N/2),:);
Y = reshape(Y,[],1);

%% Remove zeros from last package if needed
if (rem ~= 0)
    Y=Y(1:end-((N/2-1)-rem));
end



