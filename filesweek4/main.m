clear all;

% Exercise session 4: DMT-OFDM transmission scheme

% Constants
Nq=6; %max 6
N=28; %N must be even
prefix_value = 9; 
SNR=1e10; %Signal to noise ratio
L=10; %channel order

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod_2(Nq,bitStream,'bin',true);

%%%%%%%%%%%% Check remainder %%%%%%%%%%%%%%
remainder = mod(length(qamStream),(N/2 -1));

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,N,true,prefix_value,remainder);

% Channel
num=zeros(1,L);

for i=0:L
    num=[num randi(20)];
end

den=[zeros(1,L-1) 1];
H=filt(num,den);

rxOfdmStream = ofdmStream;

% Adding white noise
rxOfdmStream = awgn(rxOfdmStream, SNR);

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStream,N,true,prefix_value,remainder);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream,Nq,'bin',true);

% Compute BER
[berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
