function [Y] = ofdm_demod_stereo(noisy_x_serial,N,pre,L,rem,H1,H2,monotx,speaker,Lt,Ld,div_Ld,Mod_Ld,trainblock)

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
        X(:,k) = (1/N).*fft(noisy_x(:,k),N)./sqrt(H1.*((H1').')+H2.*((H2').'));
    end
elseif speaker == 'a'
    for k = 1:1:size(noisy_x,2)
        X(:,k) = (1/N).*fft(noisy_x(:,k),N)./H1;
    end
elseif speaker == 'b'
    for k = 1:1:size(noisy_x,2)
        X(:,k) = (1/N).*fft(noisy_x(:,k),N)./H2;
    end
end
%%
vec2 = zeros(1,Lt*(div_Ld+1)); 
vec_training = [];
vec_data = [];
for b=1:1:div_Ld
    vec_training_1 = 1:1:Lt;
    %vec2((1+(b-1)*(Lt+Ld)):(Lt+(b-1)*(Lt+Ld))) = vec_training_1+(b-1)*(Lt+Ld);
    vec_training = [vec_training (vec_training_1 +(b-1)*(Lt+Ld))];
    
    if (b < div_Ld)
    vec_data_1 = 1:1:Ld;
    vec_data = [vec_data (vec_data_1 +(b-1)*(Lt+Ld) + Lt)];
    else
    vec_data_1 = 1:1:Mod_Ld;
    vec_data = [vec_data (vec_data_1 +(b-1)*(Lt+Ld) + Lt)];
    end
end

X_data = X(:,vec_data);
X_training = X(:,vec_training);
trainblock = repmat(trainblock,1,div_Ld);
%% Channel estimation 

H_k = zeros(size(X_training,1),div_Ld);
for m = 1:1:div_Ld
    for l =1:1:size(X_training,1)
        Y_received_k = X_training(l,1+ (m-1)*Lt: Lt +(m-1)*Lt);
        X_sent_k = trainblock(l,1+ (m-1)*Lt: Lt +(m-1)*Lt);
        Y_received_k = Y_received_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
        X_sent_k = X_sent_k.'; %%%%%%M PAY ATTENTION TO THE DOT !!!!!!!
        H_k(l,m) = X_sent_k\Y_received_k; %% least square estimation
    end
end

%%
for k = 1:1:size(X_data,2)
    X_data(:,k) = X_data(:,k)./H_k(:,ceil(k./Ld)); %% =/= H_k for =/= packets
end
%% parallel to serial conversion
Y = X_data(2:(N/2),:);
Y = reshape(Y,[],1);

%% Remove zeros from last package if needed
if (rem ~= 0)
    Y=Y(1:end-((N/2-1)-rem));
end



