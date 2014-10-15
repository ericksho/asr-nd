function [D1, D2] = disjunctDictionaries(D1, D2, options)
%% returns a pair with dicctanaries disjunt as posible
% D1 and D2 dictionaries
% options:
% method, 1: difference SCIC, 2 residual difference
% threshold, threshold for filter
% mex, 'lasso' uses mexLasso, 'omp' uses mexOMP from SPAMS
% sparse_param, parameters for mex

[n1,m] = size(D1);
[n2,m] = size(D2);
D = [D1' D2']';
d = [ones(1,n1) ones(1,n2)*2]';
idx = randperm(n1+n2);

it = 1;
while it <= numel(idx)
    disp(['it ' num2str(it) '/' num2str(numel(idx)) ' - ' num2str(size(D,1))])
    i = idx(it);

	r = D(i,:);
    
    Dt = D;
    dt = d;
    
    Dt(i,:) = [];
    dt(i) = [];
        
    if ~disjuntRow(r,Dt,dt,options)
        D(i,:) = [];
        d(i) = [];
        idx(it) = [];
        
        ind = find(idx > i );
        idx(ind) = idx(ind) - 1;    
        %si eliminamos mantenemos el indice, la misma posicion sera usada
        %por un nuevo elemento
    else
        it = it + 1; %aumentamos el indice solo si no eliminamos
    end
end

D1 = D(find(d==1),:);
D2 = D(find(d==2),:);

end

function [disjunt] = disjuntRow(r,D,d,options)
    %% retorna true si r no debe ser eliminado (disjunto) y false en caso contrario
    disjunt = true;
    
    [R, SCIC, sci] = residual(D,r,d, options);
    
    switch options.method
        case 1
            %si la diferencia es menor al umbral, pertenece a casi ambas clases
            %abs(diff(R/max(R)))
            
            if abs(diff(R/max(R))) < options.threshold
               disjunt = false; 
            end    
        case 2
            %si la diferencia es menor al umbral, pertenece a casi ambas clases
            if abs(diff(SCIC)) < options.threshold
               disjunt = false; 
            end    
        case 3
            %mescla entre residuo y sci
            if min(R) < 10 && abs(diff(SCIC)) < options.threshold
                disjunt = false;
            end
    end
end

function [R, SCIC, sci] = residual(D,r, d, options)

k = 2;

switch options.mex
    case 'lasso'
        x = full(mexLasso(r',D',options.sparse_param))';
    case 'omp'
        x = full(mexOMP(r',D',options.sparse_param))';
end

% s1 = sum(abs(xt));
% s  = zeros(k,1);
% ek = zeros(k,1);

R = zeros(k,1);
Ln1_x = zeros(k,1);
for i = 1:k
    ii = d == i;
    %s(i)  = sum(abs(xt(:,ii)));
    %Rk    = (patch'-D(:,ii)*xt(:,ii)')';         % residual^2
    %ek(i) = sum(Rk.*Rk,2);
    delta_x = x;
    delta_x(:,ii) = 0;
    R(i) = norm(r' - D'*delta_x');
    Ln1_x(i) = norm(delta_x,1);
    
    SCIC(i) = (k*norm(delta_x,1)/norm(x,1)-1)/(k-1); %Sparsity Concentrarion Index in Class
end

sci = (k*max(Ln1_x)/norm(x,1)-1)/(k-1);

% sci = (k*max(s)/s1-1)/(k-1);
% [~,j] = min(ek(options.ik));
% ds = j;

    
%end of function
end