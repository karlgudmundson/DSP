function [ber] = ber(input_seq,output_seq)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
num_errors = 0;
diff = output_seq-input_seq;
for k=1:1:length(diff)
   num_errors = num_errors + (diff(k)~=0);
end
ber = num_errors./length(input_seq);

end

