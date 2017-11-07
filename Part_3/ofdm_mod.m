function [x_serial] = ofdm_mod(mod_vec,N,prefix,pre,L)
% N must be even

%% generation of the packet including each frame 
A = reshape(mod_vec,(N/2 -1),[]);
A_star = conj(A);
packet = [zeros(1,size(A,2)); A ; zeros(1,size(A,2)) ; flipud(A_star)];

%% computation of the time sequence
size_tot = size(packet,2);
x = ones(N,size_tot);
for m=1:1:size_tot
    x(:,m) = N.*ifft(packet(:,m),N);
end

%% Creating cyclic prefix 
if(pre == true)
    x_with_prefix = [x(end-L+1:end,:); x]
else
    x_with_prefix = x;
end

%% parallel to serial conversion
x_serial = reshape(x_with_prefix,[],1);
