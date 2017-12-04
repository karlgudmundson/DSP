function [] = visualize_demod_on_off(H_k,N,fs,imageData,colorMap,Ld,Lt,prefix_value,rxBitStream,Nq,N_kept,new_index_array)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
figure
time = (Ld+Lt)*(N + prefix_value)./fs;
partial_pic = [];
partial_pic_matrix = ones(size(H_k,2),length(rxBitStream));
for k = 1:1:size(H_k,2)
    end_curr = (N_kept).*Ld.*Nq;
    if k <size(H_k,2)
        partial_pic = [partial_pic;rxBitStream(1:end_curr)];
    else
        partial_pic = [partial_pic;rxBitStream(1:end)];
    end
    partial_pic_matrix(k,1:length(partial_pic)) =  partial_pic.';
    rxBitStream = rxBitStream(end_curr+1:end); %% emptying rx
end
for k = 1:1:size(H_k,2)
    H_kk = H_k(:,k);
    time_ir = ifft(H_kk,N);
    H_kk_with_zeros = zeros(N/2,1);
    H_kk_with_zeros(new_index_array) = H_kk(new_index_array);
    fourier_sig = mag2db(abs(H_kk_with_zeros));
    
    subplot(2,2,1); plot(time_ir); title(' IR in taime domain ');xlabel('Time [s]'); ylabel('Magnitude');drawnow;
    subplot(2,2,3); plot(fourier_sig); title('DFT of IR ');xlabel('frequency [Hz]'); ylabel('Magnitude [dB]');drawnow;
    subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Trasnmitted image'); drawnow;
    subplot(2,2,4); colormap(colorMap); image(bitstreamtoimage(partial_pic_matrix(k,:).',[160 120], 8)); axis image; title(['Received image']); drawnow;
    pause(time);
    
end

end

