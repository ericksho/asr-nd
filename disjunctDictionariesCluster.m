function [D1, D2] = disjunctDictionariesCluster(D1, D2, options)
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

[C,dc] = clusterSplit(D,d,options); 

D1 = C(find(dc==1),:);
D2 = C(find(dc==2),:);

end