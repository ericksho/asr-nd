function [] = iris_test()

path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';
disp('test with Left eye normalized')
test(path);

path = '/Users/esvecpar/Documents/datasets/GFI_database/Right_eye_Normalized/';
disp('\ntest with Rigth eye normalized')
test(path);
end

function [] = test(path)

files = dir2(path);

N = numel(files);
%class = 0; %0 hombre, 1 mujer

dall = [zeros(1,N/2) ones(1,N/2)]';

w = 9;
bits = 11;
desc = 'h';

filename=['ICAtextureFilters_' int2str(w) 'x' int2str(w) '_' int2str(bits) 'bit'];
load(filename, 'ICAtextureFilters');

for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    %BSIF
    I = bsif(I,ICAtextureFilters,'nh'); %'im' for grayscale, 'h'); for histogram and 'nh'); for normalized histogram
    
    Y(i,:) = I(:);
end

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
for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    %lbp
    [I,~] = Bfx_lbp(I,[],options);    % LBP features
    
    Y(i,:) = I(:);
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
for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    %clbp
    [I,~]=clbp(I,1,8,mapping,'h'); %clbp histogram in (8,1) neighborhood
    
    Y(i,:) = I(:);
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

end