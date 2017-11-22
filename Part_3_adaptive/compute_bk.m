function [bk] = compute_bk(eq,gamma,pnk)
% Computing bk with formula given. eq gives the channel freq. response

Hk = abs(eq);
bk = floor(log2(1+(Hk.^2)./(gamma.*pnk)));
bk = (bk>6).*6 + (bk<0).*0 + bk.*(bk>=0 & bk<=6); %to bound bk between 0 and 6 
end

