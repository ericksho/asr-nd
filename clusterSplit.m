function [C,d] = clusterSplit(D,d,options)
    %%kmeans de 2
    minSize = 10;
    if isfield('minSize', options)
        minSize = options.minSize;
    end
    if size(d) < minSize
        C = [];
        d = [];
        return
    end
    
    numClusters = 2;
    [~, assignments] = vl_kmeans(D', numClusters);
    
    %%mido el % de cada cluster
    Dc1 = D(find(assignments==1),:);
    dc1 = d(find(assignments==1),:);
    
    Dc2 = D(find(assignments==2),:);
    dc2 = d(find(assignments==2),:);
    
    p1c1 = sum(dc1==1)/numel(dc1); %porcentaje en cluster 1 de la clase 1
    p2c1 = sum(dc2==1)/numel(dc2); %porcentaje en cluster 2 de la clase 1
    
    %%si es menor a 90% subdivido
    minPercentaje = 0.9;
    if isfield('per', options)
        minPercentaje = options.per;
    end
    
    if p1c1 < minPercentaje && p1c1 > 1-minPercentaje
        [C1, dc1] = clusterSplit(Dc1,dc1,options);
    else
        %%si es mayor a 90% lo mantengo y elimino el 10% restante
        if p1c1 > 0.9
            C1 = Dc1(find(dc1==1),:);
            dc1 = dc1(find(dc1==1));
        else
            C1 = Dc1(find(dc1==2),:);
            dc1 = dc1(find(dc1==2))';
        end
    end
    
    if p2c1 < minPercentaje && p2c1 > 1-minPercentaje
        [C2, dc2] = clusterSplit(Dc2,dc2,options);
    else
        %%si es mayor a 90% lo mantengo y elimino el 10% restante
        if p2c1 > 0.9
            C2 = Dc2(find(dc2==1),:);
            dc2 = dc2(find(dc2==1));
        else
            C2 = Dc2(find(dc2==2),:);
            dc2 = dc2(find(dc2==2))';
        end
    end
    
    C = [C1' C2']';
    if size(dc1,1) ~= 1
        dc1 = dc1';
    end
    if size(dc2,1) ~= 1
        dc2 = dc2';
    end
    d = [dc1 dc2];
    
end