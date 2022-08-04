% Prediction Matrix for test users
randn("seed", seed_factor + algorithm);
Pr = randn(test_users,nM);    

% Sort the Pr scores descending
[~,idx] = sort(Pr,2,'descend');

% Get the sorted item ids for every user
Sorted_Items{factors} = idx;