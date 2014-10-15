%% train
function [asri_trained] = asri_train(X,d, options)
%% por cada imagen extraemos los patches
if(options.show)
    bar = waitbar(0,'Train patches extraction');
end

N = size(X,1);
Xpatches = zeros(N*options.m,options.a*options.b+2);
dpatches = zeros(N*options.m,1);

count = 1;
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
    
    Xpatches(count:count+size(patches,1)-1,:) = patches;
    dpatches(count:count+size(patches,1)-1) = ones(size(patches,1),1)*d(i);
    count = count + size(patches,1);
end

Xpatches = Xpatches(1:count-1,:);
dpatches = dpatches(1:count-1);

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
    Xpclass = Xpatches(find(dpatches==i));
    [dc, C] = Bct_kmeans(Xpclass,k);
    knn = [];
    for c = 1:k
        %% por cada cluster entrenamos un knn
        if(options.show)
            waitbar(i/N,bar,['Kmean clustering...cluster: ' num2str(i) ' - knn: ' num2str(c)]);
        end
        
        idx = find(dc==c);
        Xc = Xpclass(idx,:);
        
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