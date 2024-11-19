function mos = r2mos(r)

r = r(:);
mos = nan(length(r),1);

for i = 1:length(r)
    
    if r < 0
        mos(i) = 1;
    elseif r > 100
        mos(i) = 4.5;
    else
        mos(i) = 1 + 0.035*r(i)+r(i)*(r(i)-60)*(100-r(i))*7*10^(-6);
    end
end
end