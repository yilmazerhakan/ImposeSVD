% Adjusted Cosine Similarity
Ac=A-mean(A,2);
G = Ac'*Ac;
L2 = sqrt(diag(G));
V = G ./ (L2 .* L2');
V(isnan(V))=0;

% Most Similar item neighs
IS = zeros(nM, factors(end));
for i=1:nM,
  sims = V(i,:);
  sims(i) = 0;        
  [nsv, nsi] = sort(sims,'descend');
  IS(i,:) = nsv(1:factors(end));
endfor 

for f=1:length(factors)
  % predictions
  Vtemp=V;
  % thresholding
  for i=1:nM,
    temp=Vtemp(i,:);
    temp(temp<IS(i,factors(f)))=0;
    Vtemp(i,:)=temp;
  endfor
  
  % Prediction Matrix for test users
  Nom = Au * Vtemp;
  Denom = logical(Au) * Vtemp;
  Pr = Nom ./ Denom;
  Pr(isnan(Pr))=0;
  
  % Sort the Pr scores descending
  [~,idx] = sort(Pr,2,'descend');
  % Get the sorted item ids for every user
  Sorted_Items{f} = idx;  
end 