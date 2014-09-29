%% testing
function [ds] = asri_testing(Xt, asri_trained, options)

ds = zeros(size(Xt,2));

%% por cada imagen
for i = 1:size(Xt,2)
    I = reshape(Xt, options.w, options.w);
    v = zeros(options.n_class,1);
    
    patches = asri_getPatches(I,options);
    
    %% por cada patch
    for p = 1:size(patches)

        %% por cada clase
        D = [];
        for c = 1:options.n_class
            %% construir el diccionario usando knn
            knn_op = asri_trained{c};
            [index, distance] = vl_kdtreequery(knn_op.kdtree,knn_op.X',Xt','NumNeighbors',knn_op.k);

            Dc = knn_op.X(index,:);
            D = [D Dc];
            pi = [pi ones(size(D,2),1)*c];
        end

        %% por cada clase
        R = zeros(options.n_class,1);
        SCI = R;

        for c = 1:options.n_class
            %% calcular residuo y sci
            [r, sci] = asri_residual(D,patch, pi);
            R(c) = r;
            SCI(c) = sci;
        end

        %%%%%%%%%%%%%% pensar si filtramos el sci al votar como aca o
        %%%%%%%%%%%%%% si filtramos los votos que no cumplen con el sci

        %% filtrar por sci
        idx = find(SCI < options.sci);

        R(idx) = 100;

        %% calcular el menor residuo 
        [minR, idx] = min(R);

        %% asignar voto usando el sci
        if minR ~= 100 % quiere decir que no eliminamos todos por sci
            v(idx) = v(idx) + SCI(idx);
        end

    end

    [minV, idx] = min(v);
    ds(i) = idx;
end
        
% fin testing
end