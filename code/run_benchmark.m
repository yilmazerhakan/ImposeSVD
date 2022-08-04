%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ImposeSVD: Incrementing PureSVD for top-N recommendations for cold-start problems and sparse datasets
% 
% ABSTRACT
%In this paper, we introduced two novel collaborative filtering techniques for recommendation systems in cases of various cold-start situations and incomplete datasets. The first model establishes an asymmetric weight matrix between items without using item meta-data and eradicates the disadvantages of neighborhood approaches by automatic determination of threshold values. Our first model, z-scoREC, is also regarded as a pure deep-learning model because it performs like a vanilla auto-encoder in transforming column vectors with z-score normalization similar to batch normalization. With the second model, ImposeSVD, we aimed to enhance the shortcomings of the PureSVD in cases of cold-start and incomplete data by preserving its straightforward implementation and non-parametric form. The ImposeSVD model relies on the z-scoREC, produces synthetic new predictions for the users by decomposing the latent factors from the imposed matrix. We evaluated our method on the well-known datasets and found out that our method was outperforming similar approaches in the specific scenarios including recommendations for cold-start users, strength in cold-start systems, and diversification of long-tail item recommendations in lists. Our z-scoREC model also outperformed familiar neighbor-based approaches when operated as a recommender system and gave a closer appearance to the decomposition methods despite its simple and rigid cost framework.

% % Models
% % 1 - z-scoREC
% % 2 - ImposeSVD
% % 3 - EigenREC
% % 4 - HybridSVD
% % 5 - PureSVD
% % 6 - ItemKNN
% % 7 - ICF
% % 8 - Popular
% % 9 - Random
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
start_time=tic;

%%%%%%%%%%%%%%% DATASETs %%%%%%%%%%%%%%%%%%
% Select the benchmark dataset below (Default is Ml1M)
dataset_id = 4; % you can change for another eval.

ds_name = {};
ds_name{1} = {name="BookCrossing", dataset="bxi"};
ds_name{2} = {name="Pinterest Image", dataset="pinterest"};
ds_name{3} = {name="MovieLens 10M", dataset="ml10m"}; 
ds_name{4} = {name="MovieLens 1M", dataset="ml1m"}; 
% We didnt add Netflix and Yahoo datasets because they are not public.
dataset = ds_name{dataset_id}{2};
dataset_name = ds_name{dataset_id}{1};
disp(sprintf("Dataset: %s", dataset_name));
%%%%%%%%%%%%%%% SCENARIO %%%%%%%%%%%%%%%%%%
% you can change for another eval.
scenario = 1; % Selected Scenario

% % Scenarios
scena = {};
scena{1} = {name="Cold-start users"};
scena{2} = {name="Long-tail items"};
scena{3} = {name="General Recommends (Sparsity:final)"};
scena{4} = {name="General Recommends (Sparsity:previous)"}; 
scena{5} = {name="General Recommends (Sparsity:initial)"}; 
scenario_name = scena{scenario}{1};
disp(sprintf("Scenario: %s", scenario_name));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%  Select Algorithms For Evaluation %%%%%%%%%%%%%%%%
Algos = {"z-scoREC", "ImposeSVD", "EigenREC", "HybridSVD", ...
 "PureSVD", "ItemKNN", "ICF", "Popular", "Random"};

%% Run all algorithms (remove below comment from beginning)
ExpAlgos = 1:length(Algos);
%% Run selected algorithms (remove below comment from beginning)
% ExpAlgos = [1 2 8 9];
% ExpAlgos = [1 2];

%%%%%%%%%%%  Parameters %%%%%%%%%%%%%%%%%%%%
if ~exist('evaluation_count');  evaluation_count = 5; end;
if ~exist('factors');           factors = 0:5:100; end;
if ~exist('heldout_size');      heldout_size = 1; end;

% TOP-N List Sizes
TOP_N_S = [1 3 5 10 15 20];
selected_top_n_index = 4;

metrics={'HR','ARHR','nDCG','R-Score'};
selected_metric_for_result = 3;
selected_metric=metrics{selected_metric_for_result};
r2alfa=2; % rscore alfa parameter default
disp(sprintf("Selected Metric (%s)",selected_metric));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  Set Default Dataset Settings for f %%%%%
DatasetResult = {};
AlgoFactors = {};
for algorithm=1:length(Algos) % Algorithms
  if algorithm==1 || algorithm==8 || algorithm==9
    factors=1;
  endif
  if algorithm==6 || algorithm==7
    factors=10:10:250;
  endif  
  if algorithm==2 || algorithm==3 || algorithm==4 || algorithm==5
    if scenario==1
      factors=[1:9 10:5:50];
    elseif scenario==2
      factors=25:25:1500;
    elseif scenario==3
      factors=25:25:1500;
    elseif scenario==4      
      factors=25:25:1500;
    elseif scenario==5
      factors=25:25:1500;
    else
      factors=20:10:100;
    endif
  endif
  HeldSums = zeros(length(factors),length(TOP_N_S)*length(metrics)+3);  
  DatasetResult{algorithm} = HeldSums;
  AlgoFactors{algorithm} = factors;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% Dataset Split for helf (train, probe, test) %%%%%%%%%%%%%%%%%%%%%%
for held=1:heldout_size
  
  disp(sprintf("---Start Held %d--------",held));
  dataset_split;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  disp(sprintf("----------- Held %d Results ---------------", held));
  fprintf('%s %s %s %s %s %s %s %s %s\n', "ID", "F", "d", "@1", "@3", "@5", "@10", "@15", "@20"); 
  %%%%%%%%%%%%  Algorithms %%%%%%%%%%%%%%%%%%%%%%%%
  for algorithm=ExpAlgos % Algos
    factors = AlgoFactors{algorithm};
    Sorted_Items = {};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lambda = 0;
  
    %%%%%%%%%%%%% z-scoREC   %%%%%%%%%%%%%%%%%%%
    if algorithm==1
      lambda=0.65;
      algo_zscorec;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% IMPOSE SVD  %%%%%%%%%%%%%%%%%%%
    if algorithm==2
      lambda=0.35;
      algo_imposesvd;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% EigenREC  %%%%%%%%%%%%%%%%%%%
    if algorithm==3
      lambda = 0.2; % best in our dataset experiments for ML1M-Coldstart
      algo_eigenrec;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% HybridSVD  %%%%%%%%%%%%%%%%%%%
    if algorithm==4
      lambda = .9; % best in our dataset experiments for ML1M-Coldstart
      alpha  = .5; % side information effect
      algo_hybridsvd;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% PureSVD  %%%%%%%%%%%%%%%%%%%
    if algorithm==5
      algo_puresvd;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% ItemKNN  %%%%%%%%%%%%%%%%%%%
    if algorithm==6
      algo_itemknn;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% ICF (Sarwar)  %%%%%%%%%%%%%%%%
    if algorithm==7
      algo_icf;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% Popular  %%%%%%%%%%%%%%%%%%%%%
    if algorithm==8
      algo_popular;
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% Random (Gaussian)  %%%%%%%%%%%
    if algorithm==9
      algo_random;  
    endif
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%% Evaluation  %%%%%%%%%%%%%%%%%%%
    evaluation;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  endfor % end of algorithm for current held
  disp(sprintf("----------- end held %d-----",held));
  disp(sprintf("----------------------------"));

endfor % end of held

% Means
for algorithm=1:length(Algos) % Algos
  dsa_temp = DatasetResult{algorithm};
  dsa_temp = dsa_temp / heldout_size;
  DatasetResult{algorithm} = dsa_temp;
end

% Bests
BestResults = zeros(length(Algos),length(metrics)*length(TOP_N_S)+2);
for algorithm=1:length(Algos) % Algos
  dsa_temp = DatasetResult{algorithm};
  [hv hi] = max(dsa_temp(:, (selected_metric_for_result+3)*(length(metrics)-1)));
  BestResults(algorithm,:) = dsa_temp(hi,2:end);
end

disp(sprintf("------- Final Result (%s) -----------------",selected_metric));
fprintf('%s %s %s %s %s %s %s %s %s\n', "A", "f", "l", "@1", "@3", "@5", "@10", "@15", "@20");
for algorithm=ExpAlgos % Algos
  fprintf('%02d %03d %0.1f %.4f %.4f %.4f %.4f %.4f %.4f\n', ...
  [ algorithm BestResults(algorithm,1:2) BestResults(algorithm,(selected_metric_for_result+2):4:length(BestResults)) ]);
endfor

cHeader = {'Fac.' 'lamb' '@1' '@3' '@5' '@10' '@15' '@20'}; %dummy header
commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas
csvfile = sprintf("../results/%s_%d.csv",dataset, scenario);
%write header to file
fid = fopen(csvfile,'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
csvwrite(csvfile, [ BestResults(:,1:2) BestResults(:,(selected_metric_for_result+2):4:length(BestResults)) ], '-append');

disp("------------------------------------------");
chart;
disp("------------------------------------------");

disp(fprintf('Total Time: %.3f', toc(start_time)));