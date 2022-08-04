% Seed values for same dataset split for all methods
ds_seed = 98765;
seed_factor = (ds_seed * 10^3) + scenario + held;

TEST_USER_COUNT=100;
HEAT_USER_THRESHOLD=20;
% Random Item Count for Evaluation
RIC = 1000;
MIN_TRAIN_ITEM_COUNT = 5;
MAX_TRAIN_ITEM_COUNT = 10;

% Load dictionaried dataset
ds_file = sprintf('../data/%s.ratings',dataset);
data = importdata(ds_file);

% User Size
nU = max( max(max(data(:,1))) );
% Item Size
nM = max( max(max(data(:,2))) );

% Convert loaded raw data to sparse Rating Matrix
R = sparse(data(:,1), data(:,2), data(:,3), nU, nM);
% Convert to full matrix for normalizations
R = full(R);
% Normalize Rating matrix between the range (0,1) with dividing it max rating value
R = R/max(data(:,3));

% Load Feature Data for HybridSVD benchmark
gf = sprintf("../data/%s.genres",dataset);
genre_data = importdata(gf);
nItem = max(max(genre_data(:,1)));
nFeature = max(max(genre_data(:,2)));
F = sparse(genre_data(:,1), genre_data(:,2), 1, nM, nFeature);
F = full(logical(F));

% stats for dataset
disp(sprintf("Sparsity: %d", 1-(nnz(R)/(length(find(sum(R,2)>0))*length(find(sum(R,1)>0))))));
disp(sprintf("User Size : %d, Item Size : %d", nU, nM));
disp(sprintf("Rating Size : %d", nnz(R)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(sprintf("------------------------------"));
if scenario==1

  disp(sprintf("Cold-Start User Scenario"));

  % obtain probe set from train set
  % Probe and Test Set for Evaluation
  % Select Randomly 1.4% of the ratings from Rating Matrix
  probe_ratio = (14/1000);
  rand ("seed", seed_factor);
  Probe = logical(R) .* rand(nU, nM);
  Probe(Probe>probe_ratio)=0;
  Probe = R .* logical(Probe);

  % remove probe set from train set
  A = R-Probe;

  % keep only full ratings (1) in probe set
  Probe(Probe<1)=0;
  % find test users at least 1 item rated
  heat_users = find(sum(Probe')>0);
  disp(sprintf("Probe User Count: %d", length(heat_users)));
  disp(sprintf("Probe Test Item Count: %d", nnz(Probe)));

  % find suitable users in the Train set 
  % find the users at least rated 1 item in Train Set (criteria > 20)
  usersRatingsCountInTrain = sum(A'>0);
  % find the users' unrated item count (This must be over $RIC)
  usersUnratedCountInTrain = sum(A'<=0);
  % find suitable users' id in the train set
  countIndicesTrain =  find(usersRatingsCountInTrain>=HEAT_USER_THRESHOLD & usersUnratedCountInTrain>RIC);  

  % find suitable users in the test set   
  usersRatingsCountInProbe = sum(Probe'>0);
  % find suitable users' id in the test set
  countIndicesProbe =  find(usersRatingsCountInProbe>0);
 
  % select users who met criteria in both set
  sel_users = intersect(countIndicesProbe,countIndicesTrain);
  disp(sprintf("User's Count met criteria: %d", numel(sel_users)));
 
  rand ("seed", seed_factor); % rand seed
  udx = randperm(length(sel_users));
  % select randomly users with size of $TEST_USER_COUNT  
  % We select limited user because we will decrease their Train set ratings otherwise R could de broken
  test_users = sel_users(udx(1:min([length(udx) TEST_USER_COUNT])));
  disp(sprintf("Test User Count: %d", length(test_users)));  
  
  % convert selected test set users to coldstart users in train set
  for tu=test_users,
      % find items of current test user in the Train Set
      items = find(A(tu,:)>0);
      rand ("seed", seed_factor + tu); % seed factor different for all users
      % shift this item ids to select
      itidx = randperm(numel(items));
      % generate a random integer between 5 and 10 for to obtain current user's item count in th Train set
      keepItemCount = randi([MIN_TRAIN_ITEM_COUNT MAX_TRAIN_ITEM_COUNT]);
      % select random items with the size of $keepItemCount
      train_items = items(itidx(1:keepItemCount));
      % Except the keep items convert other items of the user to zero (unrated)
      keep = zeros(1,nM);
      keep(1,train_items) = 1;
      A(tu,:) = A(tu,:) .* keep;
  endfor 
endif


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if scenario==2
  disp(sprintf("Long-tail Items Scenario"));

  % obtain probe set from train set
  % Probe and Test Set for Evaluation
  % Select Randomly 1.4% of the ratings from Rating Matrix
  probe_ratio = (14/1000);
  rand ("seed", seed_factor);
  Probe = logical(R) .* rand(nU, nM);
  Probe(Probe>probe_ratio)=0;
  Probe = R .* logical(Probe);

  % remove probe set from train set
  A = R-Probe;

  % keep only full ratings (1) in probe set
  Probe(Probe<1)=0;
  % find test users at least 1 item rated
  heat_users = find(sum(Probe')>0);
  disp(sprintf("Probe User Count: %d", length(heat_users)));
  disp(sprintf("Probe Test Item Count: %d", nnz(Probe)));

  % find item frequencies
  item_frequencies = sum(A>0);
  % sort them by frequencies
  [item_freq item_idx] = sort(item_frequencies, 2, 'descend');
  % select popular items' total rating count (Cremonesi method)
  % As observed by the authors in this paper, the most popular 1.7% items represent 33% 
  % of the ratings included in the Netflix dataset and they called these 1.7% items as short-head items.
  popular_items = nnz(A) * (33/100);
  % obtain popular item ids
  thrashed_items=find(popular_items<=cumsum(item_freq), 1, 'first');
  % remove popular item ids from Probe set
  Probe(:,item_idx(1:thrashed_items)) = 0;

  % find suitable users in the Train set 
  % find the users at least rated 1 item in Train Set 
  usersRatingsCountInTrain = sum(A'>0);
  % find the users' unrated item count (This must be over $RIC)
  usersUnratedCountInTrain = sum(A'<=0);
  % find suitable users' id in the train set
  countIndicesTrain =  find(usersUnratedCountInTrain>RIC);  

  % find suitable users in the test set   
  usersRatingsCountInProbe = sum(Probe'>0);
  % find suitable users' id in the test set
  countIndicesProbe =  find(usersRatingsCountInProbe>0);
 
  % select users who met criteria in both set
  sel_users = intersect(countIndicesProbe,countIndicesTrain);
  disp(sprintf("User's Count met criteria: %d", numel(sel_users)));
 
  rand ("seed", seed_factor); % rand seed
  udx = randperm(length(sel_users));
  % select randomly users with size of $TEST_USER_COUNT  
  % We select limited user because of the eval time
  test_users = sel_users(udx(1:min([length(udx) TEST_USER_COUNT])));
  disp(sprintf("Test User Count: %d", length(test_users)));    
endif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if scenario==3 || scenario==4 || scenario==5
  disp(sprintf("Cold Start System Scenario"));
  % Scenario 3 -> %100
  % Scenario 4 -> %066
  % Scenario 5 -> %033
  %%%%%%%%%%%%%
  % Sparsity Subset Ratio
  sparse_ratio = 2/3;
  % if Scenario = 3 then get All rating, if scenario is 4 then 2/3 of ratings ...
  final_stage = 1 * sparse_ratio^0;
  previous_stage = 1 * sparse_ratio^1;
  initial_stage = 1 * sparse_ratio^2;

  disp(sprintf("Sparsity Percentage: %d", 1 * sparse_ratio^(scenario-3)));
  rand("seed", seed_factor+1);
  FINAL_STAGE = rand(nU, nM).* logical(R);
  
  PREVIOUS_STAGE = FINAL_STAGE;
  PREVIOUS_STAGE(PREVIOUS_STAGE>previous_stage)=0;
  PREVIOUS_STAGE = R.*logical(PREVIOUS_STAGE);
  
  INITIAL_STAGE = FINAL_STAGE;
  INITIAL_STAGE(INITIAL_STAGE>initial_stage)=0;
  INITIAL_STAGE = R.*logical(INITIAL_STAGE);

  % obtain probe set from initail stage
  % Probe and Test Set for Evaluation
  % Select Randomly 1.4% of the ratings from Rating Matrix
  probe_ratio = (14/1000);
  rand ("seed", seed_factor+2);
  Probe = logical(INITIAL_STAGE) .* rand(nU, nM);
  Probe(Probe>probe_ratio)=0;
  Probe = INITIAL_STAGE .* logical(Probe);

  if scenario==3 % final stage
    % remove probe set from final stage
    A = R-Probe;
  endif

  if scenario==4 % previous stage
    % remove probe set from previous stage
    A = PREVIOUS_STAGE-Probe;
  endif  

  if scenario==5 % initial stage
    % remove probe set from initial stage
    A = INITIAL_STAGE-Probe;
  endif  

    % keep only full ratings (1) in probe set
  Probe(Probe<1)=0;

  % find suitable users in the Train set 
  % find the users at least rated 1 item in Train Set 
  usersRatingsCountInTrain = sum(A'>0);
  % find the users' unrated item count (This must be over $RIC)
  usersUnratedCountInTrain = sum(A'<=0);
  % find suitable users' id in the train set
  countIndicesTrain =  find(usersUnratedCountInTrain>RIC);  

  % find suitable users in the test set   
  usersRatingsCountInProbe = sum(Probe'>0);
  % find suitable users' id in the test set
  countIndicesProbe =  find(usersRatingsCountInProbe>0);
 
  % select users who met criteria in both set
  sel_users = intersect(countIndicesProbe,countIndicesTrain);
  disp(sprintf("User's Count met criteria: %d", numel(sel_users)));
 
  rand ("seed", seed_factor); % rand seed
  udx = randperm(length(sel_users));
  % select randomly users with size of $TEST_USER_COUNT  
  % We select limited user because of the eval time
  test_users = sel_users(udx(1:min([length(udx) TEST_USER_COUNT])));
  disp(sprintf("Test User Count: %d", length(test_users)));    
endif


% keep test set users full ratings for evaluation from Probe set
Test_set = zeros(nU,nM);
Test_set(test_users,:)=1;
Test_set = Test_set .* Probe;

% Users' Unrated items for evaluation
##Unrated = ~logical(A);

% Train Data rating vector of test users
Au = A(test_users,:);

% Control
R=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%