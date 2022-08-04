% HybridSVD: When Collaborative Information is Not Enough

% Frolov, E., & Oseledets, I. (2019, September). HybridSVD: when collaborative information is not enough. In Proceedings of the 13th ACM conference on recommender systems (pp. 331-339).

% https://github.com/evfro/recsys19_hybridsvd

% "Where m denotes the largest element of matrix"
Z = (F*F')/nM;

% from original paper "We additionally enforce the diagonal elements of Z to be all ones"
Z = Z + eye(nM) - diag(diag(Z));
Z = full(Z);
L = chol(Z);
L(isnan(L))=0;
S = (1-alpha)*eye(nM) + alpha*L;
S = full(S);
Pa = A * S;
Pa = Pa * diag(diag(sparse(diag(sqrt(diag(Pa'*Pa)))).^(lambda-1)));
Pa(isnan(Pa)) = 0;

% Vlatents is the reduced latent-model
Vlatents = psvdx(Pa, factors(end)+10);
%
Lw = (S'\S');
Lw(isnan(Lw)) = 0;  
Av = Pa(test_users,:) * Lw;

for f=1:length(factors)
  V = Vlatents(:,1:factors(f));
  Pr = Av*V*V';
  % Sort the Pr scores descending
  [~,idx] = sort(Pr,2,'descend');
  % Get the sorted item ids for every user
  Sorted_Items{f} = idx;
end