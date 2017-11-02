function [I,mod_vec] = qam_mod(Nq,input_sequence)
%function that implements a M-QAM mdoulation  -> see constellation 
% for this project, up to 64-QAM
%sequence = input_sequence(1:M);
%I = a + 1i*b;
% truncating the #bits such that the modulation works proprely
trunc = mod(length(input_sequence),Nq);
input_sequence = input_sequence(1:end-trunc);

% Organising the input sequence in an efficient manner for modulating 
% [1 1 1 0 1 1] --> [7 3] for Nq = 3
% [1 1 1 0 1 1] --> [3 2 3] for Nq = 2
in_matrix = reshape(input_sequence,Nq,[])';
index_vector = zeros(size(in_matrix,1),1);
for l = 1:1:size(in_matrix,1)
    index_vector(l) = polyval(in_matrix(l,:),2);
end

switch Nq
case 1
a = 1;
b = 0;
a = sort([-a a]);
case 2
a = 1;
b = 1;
a = sort([-a a]);
b = sort([-b b]);
case 3
a = [1 3];
b = 1;
a = sort([-a a]);
b = sort([-b b]);
case 4 
a = [1 3];
b = [1 3];
a = sort([-a a]);
b = sort([-b b]);
case 6 
a = [1 3 5 7];
b = [1 3 5 7];
a = sort([-a a]);
b = sort([-b b]);
end

I = []; 
for k = 1:1:length(a)
    I = [I (a(k)+1i*b)];
end

%%%% Power normalisation %%%%%%%%%%%%%%%%
max_amp = (max(abs(I)));
I = I./max_amp;

%%%%%%% Modulated vector %%%%%%%%%%%%%%%%%
mod_vec = I(index_vector+1);
%%%%%%%%%%%%%%% CONSTELLATION %%%%%%%%%%%%
figure1 = figure;
axes1 = axes('Parent',figure1,'FontSize',12);
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'on');
plot(mod_vec,'Marker','x','LineWidth',3,'LineStyle','none')
axis([-1 1 -1 1]);
grid on 
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
end

