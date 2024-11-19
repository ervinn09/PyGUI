function pattern = genpatt_thilo(pl, burstR, nframes, pl_tol)
    % pl should be 0..1
    % burstR should be > 1.0
    if nargin < 4
       pl_tol = 0.01; % Default max. error allowed should be 1 percent point 
    end
    
    if burstR < 1
        error('burstR<1');
    end
    
    if pl < 0 || pl > 1
        error('pl < 0 or pl > 1');
    end
    
    pattern = zeros(1, nframes);
    
    q = (1 - pl) / burstR;
    p = (pl * q) / (1 - pl);
    
    pl_state = 0; % 0 = found state, 1 = lost state
    
    while abs((sum(pattern)/nframes)-pl) > pl_tol
        for i = 1:nframes
            pattern(i) = pl_state;
            pl_state = determineLoss(pl_state, p, q);
        end
    end
end

function pl_state = determineLoss(pl_state, p, q)
    if pl_state == 0
        if rand < p
            pl_state = 1;
        end
    elseif pl_state == 1
        if rand < q
            pl_state = 0;
        end
    end
end
