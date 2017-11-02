n = 1350;
bin_seq = randi([0 1],1,n);
dataMod = qam_mod(bin_seq);
scatterplot(dataMod,1,0,'k*');