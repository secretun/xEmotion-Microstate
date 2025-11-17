function spd = vec2spd(X)
    n = length(X);
    for i = 1:floor(sqrt(2*n))
        if i * (i+1) == 2*n
            dim = i;
            break
        end
    end
    index = 0;
    spd = zeros(dim,dim);
    for i = 1:dim
        for j = i:dim
            index = index + 1;
            if i == j
                spd(i,j) = X(index);
            else
                spd(i,j) = X(index) / sqrt(2);
                spd(j,i) = X(index) / sqrt(2);
            end
        end
    end
end