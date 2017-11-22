function [ber] = ber(input_seq,output_seq)
%Computes Bit Error Rate (BER), diffrence between transmitted and
%received bitstream
num_errors = 0;
diff = output_seq-input_seq;
for k=1:1:length(diff)
   num_errors = num_errors + (diff(k)~=0);
end
ber = num_errors./length(input_seq);

end

