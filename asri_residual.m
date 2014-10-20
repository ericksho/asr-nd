function [R, sci] = asri_residual(D,patch, dD, options)

k = options.n_class;

switch options.mex
    case 'lasso'
        x = full(mexLasso(patch',D',options.sparse_param))';
        if(sum(x) == 0)
            disp('wrong!')
        else
            disp('yey!!!!!!!')
        end
    case 'omp'
        x = full(mexOMP(patch',D',options.sparse_param))';
end

% s1 = sum(abs(xt));
% s  = zeros(k,1);
% ek = zeros(k,1);

R = zeros(k,1);
Ln1_x = zeros(k,1);
for i = 1:k
    ii = dD ~= i;
    %s(i)  = sum(abs(xt(:,ii)));
    %Rk    = (patch'-D(:,ii)*xt(:,ii)')';         % residual^2
    %ek(i) = sum(Rk.*Rk,2);
    delta_x = x;
    delta_x(:,ii) = 0;
    R(i) = norm(patch' - D'*delta_x');
    Ln1_x(i) = norm(delta_x,1);
end

sci = (k*max(Ln1_x)/norm(x,1)-1)/(k-1);

% sci = (k*max(s)/s1-1)/(k-1);
% [~,j] = min(ek(options.ik));
% ds = j;

    
%end of function
end