function [x_serial,trainpacket,lenDataPackage] = ofdm_mod_stereo(mod_vec,N,pre,L,rem,trainblock,Lt,H_1,H_2)
%% If remainder isn't equal to 0, the last package will not be full.
% This fills up the last packet with zeros if needed.
if (rem ~=0)
    mod_vec_even = mod_vec(1:end-rem);    
    last_package = [mod_vec(end-rem+1:end); zeros((N/2-1)-rem,1)];
    A = [reshape(mod_vec_even,(N/2 -1),[]), last_package];
else
    A = reshape(mod_vec,(N/2 -1),[]);
end

%% training packet reshape 
trainpacket = reshape(trainblock,(N/2 -1),[]);
if(size(trainpacket,2) == Lt)
else
    error('Training packet is wrong');
end
Training_star = conj(trainpacket);
trainpacket = [zeros(1,size(trainpacket,2)); trainpacket ; zeros(1,size(trainpacket,2)) ; flipud(Training_star)];
%% generation of the packet including each frame 
A_star = conj(A);
packet = [zeros(1,size(A,2)); A ; zeros(1,size(A,2)) ; flipud(A_star)];

%% Filtering data packet 
denum_H = sqrt(H_1.*((H_1').') + H_2.*((H_2').') );
filter_a = ((H_1').')./denum_H;
filter_b = ((H_2').')./denum_H;
packet_a = zeros(size(packet));
packet_b = zeros(size(packet));
for l =1:1:size(packet,2)
    packet_a(:,l) = (filter_a).*packet(:,l);
    packet_b(:,l) = (filter_b).*packet(:,l);
end
%% Generation of the total packet including training frames and data frames
Total_packet_a = [trainpacket,packet_a];
Total_packet_b = [trainpacket,packet_b];
lenDataPackage = size(packet);
%% computation of the time sequence including training frames and data frames
size_tot = size(Total_packet_a,2);
x_a = ones(N,size_tot);
x_b = ones(N,size_tot);
for m=1:1:size_tot
    x_a(:,m) = 1.*ifft(Total_packet_a(:,m),N);
    x_b(:,m) = 1.*ifft(Total_packet_b(:,m),N);
end

%% Creating cyclic prefix 
if(pre == true)
    x_with_prefix_a = [x_a(end-L+1:end,:); x_a];
    x_with_prefix_b = [x_b(end-L+1:end,:); x_b];
else
    x_with_prefix_a = x_a;
    x_with_prefix_b = x_b;
end

%% parallel to serial conversion
x_serial_a = reshape(x_with_prefix_a,[],1);
x_serial_b = reshape(x_with_prefix_b,[],1);

x_serial = [x_serial_b, x_serial_a];

