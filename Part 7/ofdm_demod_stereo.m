function [Y] = ofdm_demod_stereo(noisy_x_serial,N,pre,L,rem,H1,H2,monotx,speaker)

%% Serial to parallel conversion and removing prefixs
if (pre == true)    
    noisy_x = reshape(noisy_x_serial,(N+L),[]);
    noisy_x = noisy_x(L+1:end,:);
else 
    noisy_x = reshape(noisy_x_serial,(N),[]);
end

%% OFDM demodulation process
%Equalizing because of added cyclic prefix

X = zeros(size(noisy_x));

if ~monotx
    for k = 1:1:size(noisy_x,2)
        X(:,k) = 1.*fft(noisy_x(:,k),N)./sqrt(H1(k).*H1(k)'+H2(k).*H2(k)');
    end
elseif speaker == 'a'
    for k = 1:1:size(noisy_x,2)
        X(:,k) = 1.*fft(noisy_x(:,k),N)./H1;
    end
elseif speaker == 'b'
    for k = 1:1:size(noisy_x,2)
        X(:,k) = 1.*fft(noisy_x(:,k),N)./H2;
    end
end
%% parallel to serial conversion
Y = X(2:(N/2),:);
Y = reshape(Y,[],1);

%% Remove zeros from last package if needed
if (rem ~= 0)
    Y=Y(1:end-((N/2-1)-rem));
end



