% Implementation of the EigenRec algorithm for top-N recommendations. The algorithm is presented in the paper:

% A. N. Nikolakopoulos, V. Kalantzis, E. Gallopoulos and J. D. Garofalakis, "EigenRec: Generalizing PureSVD for % Effective and Efficient Top-N Recommendations," Knowl. Inf. Syst., 2018. doi: 10.1007/s10115-018-1197-7 .

% https://github.com/nikolakopoulos/EigenRec

% The inter-item similarity matrix A_cos = W'*W
G = A'*A;
S = diag(diag(sparse(diag(sqrt(diag(G)))).^(lambda-1)));
% 
W = A * S;
W(isnan(W))=0;
OPTS.issym = 1; 
OPTS.tol = 1e-8;
% Vlatents is the reduced latent-model
[Vlatents,~] = eigs(@(x)eigenrec_afunc(x,W),nM,factors(end)+10,'LM',OPTS); 
% 
for f=1:length(factors)
  V = Vlatents(:,1:factors(f));
  Pr = Au*V*V';
  % Sort the Pr scores descending
  [~,idx] = sort(Pr,2,'descend');
  % Get the sorted item ids for every user
  Sorted_Items{f} = idx;
end