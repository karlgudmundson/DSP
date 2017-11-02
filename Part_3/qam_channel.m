function [noisy_mod_vec] = qam_channel(mod_vec,SNR)
%This functions use a vector of modluated symbols as input and returns a
%noisy vector that simulates a realistic communication channel.
noisy_mod_vec = awgn(mod_vec, SNR);
figure1 = figure;
axes1 = axes('Parent',figure1,'FontSize',12);
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'on');
plot(noisy_mod_vec,'Marker','x','LineWidth',3,'LineStyle','none')
axis([-1.3 1.3 -1.3 1.3]);
grid on 
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
scatterplot(noisy_mod_vec);
end

