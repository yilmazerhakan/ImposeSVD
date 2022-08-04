% Result Matrix
% Results will be calculated for all Factor Size
result_row_size=length(metrics)*length(TOP_N_S);
Experiment_Results = zeros(result_row_size, length(factors));

for repeat_id=1:evaluation_count
    eval_results = arrayfun( @(z)metric_eval(z, Test_set(test_users(z),:), ~logical(Au(z,:)), nM, seed_factor + repeat_id + z, ...    
    RIC, cellfun(@(v)v(z,:), Sorted_Items, 'un', false), TOP_N_S, factors, r2alfa, result_row_size), 1:length(test_users), ...
    "UniformOutput", false);
    for uis=1:1:length(test_users)
      Experiment_Results += eval_results{uis};
    endfor    
endfor

Experiment_Results = Experiment_Results' / (nnz(Test_set) * evaluation_count);

HeldResult=[];
for f=1:length(factors)
    HeldResult(end+1,:) = [held, factors(f), lambda, Experiment_Results(f,1:result_row_size) ];
endfor
dsa_temp = DatasetResult{algorithm} + HeldResult;
DatasetResult{algorithm} = dsa_temp;
  
[hv hi] = max(HeldResult(:, (selected_metric_for_result+3)*(length(metrics)-1)));
HeldResult=HeldResult(hi,:);
fprintf('%02d %03d %.2f %.4f %.4f %.4f %.4f %.4f %.4f\n', ...
[algorithm HeldResult(:, [2 3 (selected_metric_for_result+3):4:((length(TOP_N_S)+1)*4) ] ) ]);