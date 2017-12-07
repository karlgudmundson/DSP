function [x_serial,trainpacket,lenDataPackage] = ofdm_mod7(mod_vec,N,pre,L,rem,trainblock,Lt)
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

%% Generation of the total packet including training frames and data frames
% div_Ld = ceil(size(packet,2)./Ld);
% Mod_Ld = mod(size(packet,2),Ld);
% Total_packet = [];
% for b=1:1:div_Ld
%     if (b < div_Ld)
%         Total_packet = [Total_packet,trainpacket,packet(:,Ld*(b-1)+1:Ld*(b-1)+Ld)];
%     else
%         Total_packet = [Total_packet,trainpacket,packet(:,Ld*(b-1)+1:end)];
% 
%     end
% end
Total_packet = [trainpacket,packet];
lenDataPackage = size(packet);
%% computation of the time sequence including training frames and data frames
size_tot = size(Total_packet,2);
x = ones(N,size_tot);
for m=1:1:size_tot
    x(:,m) = N.*ifft(Total_packet(:,m),N);
end

%% Creating cyclic prefix 
if(pre == true)
    x_with_prefix = [x(end-L+1:end,:); x];
else
    x_with_prefix = x;
end

%% parallel to serial conversion
x_serial = reshape(x_with_prefix,[],1);

