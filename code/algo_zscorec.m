% Gram Matrix in Eq. (2)
G = A'*A;

% Our Novel Item Weight Matrix in Eq. (7)
W = G  - lambda*diag(G); 

% z-score normalization in Eq. (8)
K = zscore(W); 

% set negative values as zero
K(isnan(K))=0;
K(K<0)=0;

% Prediction Matrix for test users
Pr = Au*K;

% Sort the Pr scores descending
[~,idx] = sort(Pr,2,'descend');

% Get the sorted item ids for every user
Sorted_Items{factors} = idx;