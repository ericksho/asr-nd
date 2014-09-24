clear
path = '/Users/esvecpar/Documents/datasets/faces_orl';

files = dir(path);

class = 1;
for i=1:numel(files)-2
    d(i) = class;
    if i/10==uint8(i/10)
        class = class+1;
    end
end
dall = d';

w = 9;
bits = 11;
desc = 'h';

filename=['ICAtextureFilters_' int2str(w) 'x' int2str(w) '_' int2str(bits) 'bit'];
load(filename, 'ICAtextureFilters');

for i1 = 1:numel(files)-2
    i = i1+2;
    I = imread([path '/' files(i).name]);
    %BSIF
    I = bsif(I,ICAtextureFilters,'nh'); %'im' for grayscale, 'h'); for histogram and 'nh'); for normalized histogram
    
    Y(i1,:) = I(:);
end

%%
% [X,d,Xt,dt] = Bds_stratify(Y,dall,0.9);
% 
% op.k = 10;
% ds = Bcl_knn(X,d,Xt,op);   % knn with 10 neighbors
% p = Bev_performance(ds,dt) % performance on test data

%%
disp(['using descriptor: ' desc ' for bsif and 10 cross-val: ']);
b(1).name = 'knn';   b(1).options.k = 1;                              % KNN with 5 neighbors
b(2).name = 'knn';   b(2).options.k = 3;                              % KNN with 7 neighbors
b(3).name = 'knn';   b(3).options.k = 5;                              % KNN with 9 neighbors
b(4).name = 'knn';   b(4).options.k = 7;                              % KNN with 9 neighbors
b(5).name = 'knn';   b(5).options.k = 9;                              % KNN with 9 neighbors
op.strat=1; op.b = b; op.v = 10; op.show = 1; op.c = 0.95;        	  % 10 groups cross-validation
[p,ci] = Bev_crossval(Y,dall,op);                                        % cross valitadion

%% using LBP %%%%%%%%%%%%%%%%%%%%%%%%% using LBP %%%%%%%%%%%%%%%%%%%%%%%%% using LBP %%%%%%%%%%%%%%%%%%%%%%%%% using LBP %%%%%%%%%%%%%%%%%%%%%%%%% using LBP %%%%%%%%%%%%%%%%%%%%%%%%% using LBP %%%%%%%%%%%%%%%%%%%%%%%
options.vdiv = 1;                  % one vertical divition
options.hdiv = 1;                  % one horizontal divition
options.semantic = 0;              % classic LBP
options.samples  = 8;              % number of neighbor samples
options.mappingtype = 'u2';        % uniform LBP
%options.mappingtype = 'ri';        % rotation-invariant LBP

clear Y
for i1 = 1:numel(files)-2
    i = i1+2;
    I = imread([path '/' files(i).name]);
    %BSIF
    [I,~] = Bfx_lbp(I,[],options);    % LBP features
    
    Y(i1,:) = I(:);
end
%%
disp(['using descriptor: ' options.mappingtype ' for LBP and 10 cross-val: ']);
b(1).name = 'knn';   b(1).options.k = 1;                              % KNN with 5 neighbors
b(2).name = 'knn';   b(2).options.k = 3;                              % KNN with 7 neighbors
b(3).name = 'knn';   b(3).options.k = 5;                              % KNN with 9 neighbors
b(4).name = 'knn';   b(4).options.k = 7;                              % KNN with 9 neighbors
b(5).name = 'knn';   b(5).options.k = 9;                              % KNN with 9 neighbors
op.strat=1; op.b = b; op.v = 10; op.show = 1; op.c = 0.95;        	  % 10 groups cross-validation
[p,ci] = Bev_crossval(Y,dall,op);                                        % cross valitadion

%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%% using CLBP %%%%%%%%%%%%%%%%%%%%%%%%
map = 'u2';
mapping=getmapping(8,map); 

clear Y
for i1 = 1:numel(files)-2
    i = i1+2;
    I = imread([path '/' files(i).name]);
    %BSIF
    [I,~]=clbp(I,1,8,mapping,'h'); %clbp histogram in (8,1) neighborhood
    
    Y(i1,:) = I(:);
end
%%
disp(['using descriptor: ' map ' for CLBP and 10 cross-val: ']);
b(1).name = 'knn';   b(1).options.k = 1;                              % KNN with 5 neighbors
b(2).name = 'knn';   b(2).options.k = 3;                              % KNN with 7 neighbors
b(3).name = 'knn';   b(3).options.k = 5;                              % KNN with 9 neighbors
b(4).name = 'knn';   b(4).options.k = 7;                              % KNN with 9 neighbors
b(5).name = 'knn';   b(5).options.k = 9;                              % KNN with 9 neighbors
op.strat=1; op.b = b; op.v = 10; op.show = 1; op.c = 0.95;        	  % 10 groups cross-validation
[p,ci] = Bev_crossval(Y,dall,op);                                        % cross valitadion