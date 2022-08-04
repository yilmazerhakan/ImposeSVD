function [results] = metric_eval(ui, pruid, urated, nM, seed_factor, RIC, prpuser, NSS, fs, r2alfa, result_size)
    % pkg load statistics;
    test_predicts = find(pruid>0)';
    nTp = length(test_predicts);
    RandomItems = zeros(nTp,nM);

    for pr=1:nTp
        predict = test_predicts(pr);
        rand ("seed", seed_factor + pr);
        randos = rand(1,nM).*urated;
        randos(predict) = 0;
        [prv, pri] = sort(randos, 'descend');
        thresholds = pri(1:RIC);
        RandomItems(pr,predict) = 1;            
        RandomItems(pr,thresholds) = 1;
    endfor

    % Vectorized (RandomItems are indice of real but v is sorted)
    % Be careful for the user unrated items lower than (nM-RIC), dont evaluate such users.
    TOPNS = cellfun(@(v) reshape( nonzeros( (RandomItems(:,v).*v).'  ), RIC+1, nTp ) .' (:,1:1:(RIC+1)) , prpuser, 'un', false);
    [aa bb] = size(test_predicts);
    if aa<bb
      test_predicts = test_predicts';
    endif
    results = zeros(result_size,length(fs));
    res_counter = 1;

    for nssid=1:1:length(NSS),
        ars = 1 ./ (1:1:NSS(nssid));
        ars(isnan(ars))=0;
        logars = 1 ./ (log2(2:1:(NSS(nssid)+1)));
        logars(isnan(logars))=0;
        if nssid==1
            rsars = zeros(1,RIC+1);
        else
            rsars = max([1, 0])./(2.^(([1:RIC+1]-1)./(NSS(nssid)-1)));
        endif
        rsars(isnan(rsars) | isinf(rsars))=0;
        
        hits = cellfun(@(v)v(1:1:NSS(nssid))==test_predicts, TOPNS, 'un', false);
        rhits = cellfun(@(v)v==test_predicts, TOPNS, 'un', false);

        % HR
        hr =  cellfun(@(x)sum(sum(x)), hits, 'un', false);
        results(res_counter++,:) += cell2mat(hr);
        % ARHR
        arhr =  cellfun(@(x)sum(sum(x.*ars)), hits, 'un', false);
        results(res_counter++,:) += cell2mat(arhr);
        % NDCG
        ndcg =  cellfun(@(x)sum(sum(x.*logars)), hits, 'un', false);
        results(res_counter++,:) += cell2mat(ndcg);
        % R-SCORE
        rscore =  cellfun(@(x)sum(sum(x.*rsars)), rhits, 'un', false);  
        results(res_counter++,:) += cell2mat(rscore);      
    endfor
endfunction