%% testing
function [ds] = asri_test(Xt, asri_trained, options)

ds = zeros(size(Xt,1),1);

if(options.show)
    bar = waitbar(0,'Train patches extraction');
end

%% por cada imagen
N = size(Xt,1);
V = zeros(N,2);
V2 = zeros(N,2);
for i = 1:N
    %% extraemos patches
    I = reshape(Xt(i,:), options.h, options.w);
    v = zeros(options.n_class,1);
    v2 = v;
    
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
    
    %% por cada patch
    for p = 1:size(patches,1)
        
        if(options.show)
            waitbar(i/N,bar,['Testing image: ' num2str(i) ' processing patch : ' num2str(p)]);
        end
        patch = patches(p,:);

        %% por cada clase
        D = [];
        dD = [];
        for c = 1:options.n_class
            %% construir el diccionario usando knn 
            knn_op = asri_trained{c}.main_knn;
            
            %% buscamos el mas cercano de los clusters
            [closestCluster, ~] = vl_kdtreequery(knn_op.kdtree,knn_op.X',patch','NumNeighbors',1);
            
            %% construmios el diccionario con los k mas parecidos del cluster
            knn_models = asri_trained{c}.knn;
            
            knn_op = knn_models{closestCluster};
%             try
            [index, ~] = vl_kdtreequery(knn_op.kdtree,knn_op.X',patch','NumNeighbors',knn_op.k);

            Dc = knn_op.X(index,:);
%             catch
%                 disp('failed at construct dictionary from cluster')
%             end
            D = [D' Dc']';
            dD = [dD' ones(1,size(Dc,1))*c]';
        end

        %% por cada clase
        R = zeros(options.n_class,1);

        %% calcular residuo y sci
        [R, sci] = asri_residual(D,patch, dD, options);

        %%%%%%%%%%%%%% pensar si filtramos el sci al votar como aca o
        %%%%%%%%%%%%%% si filtramos los votos que no cumplen con el sci

        %% filtrar por sci
        %idx = find(SCIC < options.sci);
        %R(idx) = 100;

        %% calcular el menor residuo 
        [~, idx] = min(R);

        %% asignar voto usando el sci
        if sci > options.sci
            %v(idx) = v(idx) + sci;
            v2(idx) = v2(idx) + sci;
            v(idx) = v(idx) + 1;
        end
        %v(idx) = v(idx) + SCIC(idx);

    end
    V(i,:) = v;
    V2(i,:) = v2;
    [~, idx] = max(v);
    ds(i) = idx;
end

save 'test.mat'
        
if(options.show)
    close(bar);
end

% fin testing
end