clear all;
close all;

%Constants
fs = 44100; %sample freq
N = 1000; %qam symbol length 
Nq = 6; %QAM modulation size
bitStream=randi([0 1], N*Nq, 1);
Xk=qam_mod_2(Nq,bitStream,'bin',true); %qam modulation
%Xk is desired signal

Hk=zeros(length(Xk),1);
Hk(1)=randi([-30 30])+1i*randi([-30 30]);

for L=1:length(Xk)-1
    
    Hk(L+1)=Hk(L)+randi([-1 1])+1i*randi([-1 1]); %Adding noise is not usefull for seeing convergence
    %Channel changes pretty slowly
    
end    

Yk=Hk.*Xk; %Yk is received signal

delta = 2 + 2i;

Wk = 1/Hk(1)'+delta; %complex conjugate, should be without dot ;)
errorSig = zeros(1,length(Wk));
errorSig(1) = delta;

%NLMS

mu = .1; %should be between 0 and 2 (for NLMS)
%lower my is more stable but converges slower
%my too high can give unstable Wk
alpha = 0.1; %avoid to divid by 0--> choosing 0.1 is ok but the smartest way of doing this is measuring the mean value of U*U' and taking a value that make sense

%%% Computation of Xk(L+1) = Yk(L+1)*Wk(L)'
%qammod(sequence, M,mapping, 'InputType', 'bit', 'UnitAveragePower', UnitAveragePower, 'PlotConstellation', true);
for L=1:size(Xk)-1
    X_k_tild = Wk(L)'*Yk(L+1);
    %X_k_hat = qammod(qamdemod(X_k_tild,2^Nq,'bin','OutputType', 'bit','UnitAveragePower', true),2^Nq,'bin','InputType', 'bit','UnitAveragePower', true);
    X_k_hat = Xk(L+1);
    Wk(L+1) = Wk(L) + mu*Yk(L+1)*conj(X_k_hat-Wk(L)'*Yk(L+1))/(alpha + Yk(L+1)'*Yk(L+1)); %% What about alpha ? 
    errorSig(L+1) = Wk(L+1) - 1/Hk(L+1)';
    
end

L=1:1000;
figure;
plot(L,real(Wk)); title('Real part of filter');
figure;
plot(L,imag(Wk)); title('Imaginary part of filter');
figure;
plot(real(Wk), imag(Wk), 'bo'); title('Real vs imaginary axes of Wk');
figure;
plot(L,abs(errorSig)); title('Difference between filter and inverse of channel');

