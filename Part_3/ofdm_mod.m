function [x_serial] = ofdm_mod(mod_vec,N)
% N must be even

%% generation of the packet including each frame 
A = reshape(mod_vec,(N/2 -1),[]);
A_star = conj(A);
packet = [zeros(1,size(A,2)); A ; zeros(1,size(A,2)) ; flipud(A_star)];

%% computation of the time sequence
k = 0:1:N-1;
n = 0:1:N-1;
size_tot = size(packet,2);

for m=1:1:size_tot
%     for l=1:1:N
%         x(l,m) = exp(1i*k(l)*2*pi.*n/N)*packet(:,m);
%     end
    x(:,m) = N.*ifft(packet(:,m),N);
end

x_test=ifft(packet);

%% parallel to serial conversion
x_serial = reshape(x,[],1);




