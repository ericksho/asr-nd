%% train
function [asri_trained] = asri_train(X,d, options)
%% por cada imagen extraemos los patches
Xpatches = [];
dpatches = [];

if(options.show)
    bar = waitbar(0,'Train patches extraction');
end
N = size(X,1);
for i = 1:N
    if(options.show)
        waitbar(i/N,bar,['Train patches extraction...image: ' num2str(i)]);
    end
    I = reshape(X(i,:),options.h,options.w);
    [z, x] = asri_getPatches(I,options);
    
    del = [];
    for j=1:size(z,1)
        zp = z(j,:);
        if sum(zp==0)/numel(zp) > options.nan_threshold %porcentaje de zeros aceptados para agregar un patch
            del = [del j];
        end
    end
    z(del,:) = [];
    x(del,:) = [];
    
    patches = asri_descriptor(z,x,options);
    
    Xpatches = [Xpatches' patches']';
    dpatches = [dpatches' ones(1,size(patches,1))*d(i)]';
end

if(options.show)
    close(bar);
end
%load('patches.mat')
%% por cada clase
N = numel(unique(d));

k = options.kmeans_k;
op.k = options.knn_k;
asri_trained = [];

if(options.show)
    bar = waitbar(0,'Kmean clustering');
end

for i = 1:N
    %% cluster por kmeans
    
    [dc, C] = Bct_kmeans(Xpatches,k);
    knn = [];
    for c = 1:k
        %% por cada cluster entrenamos un knn
        if(options.show)
            waitbar(i/N,bar,['Kmean clustering...cluster: ' num2str(i) ' - knn: ' num2str(c)]);
        end
        
        idx = find(dc==c);
        Xc = Xpatches(idx,:);
        
        op = Bcl_knn(Xc,dc(idx),op);      % knn with 10 neighbors
        knn{c} = op;
    end
    
    %% entrenamos un knn con los centroides
    op.k = 1;
    op = Bcl_knn(C,1:size(C,1),op);
    
    %% guardamos los modelos
    asri_trained{i}.knn = knn;
    asri_trained{i}.C = C;
    asri_trained{i}.dc = dc;
    asri_trained{i}.main_knn = op;
    
end

if(options.show)
    close(bar);
end

%end file
end