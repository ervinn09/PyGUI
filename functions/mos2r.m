function r = mos2r(mos)
r = nan(length(mos),1);

for i = 1:size(mos,1)
    for j = 1:size(mos,2)
        
        
        mosI = mos(i,j);
        x = 18566 - 6750 * mosI;
        y = 15 * sqrt( -903522 + 1113960 * mosI - 202500 * mosI.^2 );
        
        h = 1/3 * atan2(y, x);
        
        rI = 20/3 * ( 8 - sqrt(226) * cos( h + pi/3 ) );
        
        if rI < 6.5 || rI > 100
            error('r must be between 6.5 - 100, r=%0.2f', rI)
        end
        
        r(i,j) = rI;
    end
end
end