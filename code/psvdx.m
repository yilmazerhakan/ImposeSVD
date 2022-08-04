function V = psvdx(X,k)
% Input:
% X : m x n matrix
% k : extracts the first k singular values
%
% Output:
% X = U*S*V' approximately (up to k)
%
% Description:
% Does equivalent to svds(X,k) but faster
% Requires that k < min(m,n) where [m,n] = size(X)
% This function is useful if k is much smaller than m and n
% or if X is sparse (see doc eigs)
%
[m,n] = size(X);
OPTS.issym = 1; OPTS.tol = 1e-8;
assert(k <= m && k <= n, 'k needs to be smaller than size(X,1) and size(X,2)');
if  m <= n
    [U,D] = eigs(X*X',k,'LM',OPTS);
    V = X'*U;
    s = sqrt(abs(diag(D)));
    V = bsxfun(@(x,c)x./c, V, s');
else
    [V,~] = eigs(X'*X,k,'LM',OPTS);
end