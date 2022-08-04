% Vlatents is the reduced latent-model
Vlatents = psvdx(A, factors(end)+10);

for f=1:length(factors)
    V = Vlatents(:,1:factors(f));
    Pr = Au*V*V';
    % Sort the Pr scores descending
    [~,idx] = sort(Pr,2,'descend');
    % Get the sorted item ids for every user
    Sorted_Items{f} = idx;
end