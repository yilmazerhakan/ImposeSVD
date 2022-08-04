% Gram Matrix in Eq. (2)
G = A'*A;

% Our Novel Item Weight Matrix in Eq. (7)
W = G  - lambda*diag(G); 

% z-score normalization in Eq. (8)
K = zscore(W); 

% set negative values as zero
K(isnan(K))=0; K(K<0)=0;

% Rpriori matrix for unrated item predictions Eq. (16)
Rpriori = (A*K).*~logical(A);

% Rpriori L-inf normalization Eq. (17)
Rinf = Rpriori ./ norm(Rpriori,"inf", "rows");  
Rinf(isnan(Rinf))=0;

% Rexp exponential scale Eq. (18)
Rexp = exp(-1./Rinf); 
Rexp(isnan(Rexp))=0;

% Rimpose matrix merge with original matrix Eq. (19)
Rimpose = A + Rexp;

% Rimpose matrix merge with original matrix Eq. (20)
Vlatents = psvdx(Rimpose, factors(end)+10);    

% Test users predicted ratings for fast calculate
Riu = Rimpose(test_users,:);

% Prediction vectors from latent factors
for f=1:length(factors)
    V = Vlatents(:,1:factors(f));
    Pr = Riu*V*V';  % Eq. (21)
    % Sort the Pr scores descending
    [~,idx] = sort(Pr,2,'descend');
    % Get the sorted item ids for every user
    Sorted_Items{f} = idx;
end