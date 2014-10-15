function [Ds,dc] = shiftReduceDictionary(D,d,options)

if ~isfield(options, 'sigma');
    options.sigma = 3.2;
end

if ~isfield(options, 'clusterPercentage');
    options.clusterPercentage = 0.7;
end

dc = Bct_meanshift(D,options.sigma);

%por cada cluster
Ds = [];
ds = [];
count = 1;
for i = 1:max(dc)
    idx = find(dc == i);
    Dc = D(idx,:);
    dc = d(idx);
    
    % con esto eliminamos los cluster que estan muy mezclados
    if sum(dc==1)/numel(dc) > options.clusterPercentage
        ds(count) = 1;
        Ds(count,:) = mean(Dc);
        count = count+1;
    elseif sum(dc==2)/numel(dc) > options.clusterPercentage
        ds(count) = 2;
        Ds(count,:) = mean(Dc);
        count = count+1;
    end
end

end