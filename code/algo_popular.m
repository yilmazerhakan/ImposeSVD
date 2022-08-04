% Frequency of items
Freq = sum(logical(A), 1);

% Prediction Matrix for test users  
Pr = repmat(Freq, length(test_users), 1);    

% Sort the Pr scores descending
[~,idx] = sort(Pr,2,'descend');

% Get the sorted item ids for every user
Sorted_Items{factors} = idx;  