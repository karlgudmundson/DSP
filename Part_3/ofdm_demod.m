function [ x_mod ] = ofdm_demod( x_Rx, N )

A = reshape(x_Rx, N,[]);
x_mod = ones(N,size(A,2));

for m=1:1:size(A,2)
    x_mod(:,m) = N.\ifft(A(:,m),N);
end 

end

