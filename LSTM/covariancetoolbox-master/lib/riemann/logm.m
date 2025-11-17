function Out = logm(X)
% elta = 0.001;         %%%%%
% I = eye(size(X,1));     %%%%%
% [V,D] = eig(X+elta*I);  
[V,D] = eig(X);
% diag_D = diag(D);
% index = find(diag_D==0);
% diag_D(index) = elta;
Out = V*diag(log(diag(D)))*V';
end
