%% train
function [asri_trained] = asri_train(Xpatches,dpatches, options)
%% por cada clase
N = numel(unique(d));

k = options.kmeans_k;
op.k = options.knn_k;
asri_trained = [];

for i = 1:N
    %% cluster por kmeans
    dc = Bct_kmeans(Xpatches,k);
    knn = [];
    for c = 1:k
        %% por cada cluster entrenamos un knn
        Xc = Xpatches(c);z
        
        op = Bcl_knn(Xc,dc,op);      % knn with 10 neighbors
        knn{c} = op;
    end
    asri_trained{i} = knn;
    
end

%end file
end