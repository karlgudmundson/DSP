function [x_serial] = ofdm_mod_on_off(mod_vec,N,pre,L,rem,new_index_array)

N_kept = length(new_index_array);

%% If remainder isn't equal to 0, the last package will not be full.
% This fills up the last packet with zeros if needed.

if (rem ~=0)
    mod_vec_even = mod_vec(1:end-rem);    
    last_package = [mod_vec(end-rem+1:end); zeros((N_kept)-rem,1)];
    A = [reshape(mod_vec_even,(N_kept),[]), last_package];
else
    A = reshape(mod_vec,(N_kept),[]);
end

%% generation of new packet. 
% Sets 0 for every freq bin that isn't in new_index_array

A_on_off = zeros((N/2 -1),size(A,2));
for l = 1:1:size(A,2)
   A_on_off(new_index_array,l)  = A(:,l);
end

%% generation of the packet including each frame 
A_star = conj(A_on_off);
packet = [zeros(1,size(A_on_off,2)); A_on_off ; zeros(1,size(A_on_off,2)) ; flipud(A_star)];

%% computation of the time sequence
size_tot = size(packet,2);
x = ones(N,size_tot);
for m=1:1:size_tot
    x(:,m) = N.*ifft(packet(:,m),N);
end

%% Creating cyclic prefix 
if(pre == true)
    x_with_prefix = [x(end-L+1:end,:); x];
else
    x_with_prefix = x;
end

%% parallel to serial conversion
x_serial = reshape(x_with_prefix,[],1);