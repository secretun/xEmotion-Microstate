function spd = max_eig(X)
    [u,s] = eig(X);
    elta = 0.01;
    for i = 1:size(s,1)
       if s(i,i) < elta
           s(i,i) = elta;
       end
    end
    spd = u * s * u';
end