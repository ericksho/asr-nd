    
load feas
load idx.mat

N = 1500;

d=(Labels==0)+1;

Y = B3_total;

Ycv = Y(train,:);
dcv = d(train);
Yv = Y(test,:);
dv = d(test);

foldIdx = crossvalind('Kfold',dcv,10);

save('feas_transf.mat')

