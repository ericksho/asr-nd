function [p] = splitSrc_test(w,bits,mex,rows,opsel)
%
% metodo de Robust Face Recognition via Sparse Representation - Wright (PAMI 2007)
% probado en la base de datos de de Iris
% validacion: stratified hold out (90% training 10% testing)

path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';

files = dir2(path);

N = numel(files);
%class = 0; %0 hombre, 1 mujer

dall = [zeros(1,N/2) ones(1,N/2)]';

filename=['ICAtextureFilters_' int2str(w) 'x' int2str(w) '_' int2str(bits) 'bit'];
load(filename, 'ICAtextureFilters');

Y = zeros(numel(files),4096);
for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    %%%
    %I = decorrstretch(I); 91.6
    %%%
%     H = padarray(2,[2 2]) - fspecial('gaussian' ,[5 5],2);
%     I = imfilter(I,H);
    %%%
    %BSIF
    I = I(rows,:);
    I = bsif(I,ICAtextureFilters,'h'); %'im' for grayscale, 'h'); for histogram and 'nh'); for normalized histogram
    I(1) = 0;
    I = I/norm(I);
    Y(i,:) = I(:);
end


% normalization
Yn = zeros(size(Y));
for i=1:N
    Yn(i,:) = Y(i,:)/norm(Y(i,:));
end



d = dall+1;

%%%%
s = Bfs_sfs(Yn,d,opsel);           % index of selected features
Yn = Yn(:,s);                       % selected features
%%%%

%% %%%%%%%%%%%%%%

c = 2;   % number of classes

if mex == 1
    options.mex = 'omp';
    % parameter of the optimization procedure are chosen
    param.L=10; % not more than 10 non-zeros coefficients
    param.eps=0.1; % squared norm of the residual should be less than 0.1
    param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                    % and uses all the cores of the machine
else
    options.mex = 'lasso';
    param.lambda=0.15; % not more than 20 non-zeros coefficients
    param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                         % and uses all the cores of the machine
    param.mode=2;        % penalized formulation
end
          
%% 10 k cross validation

indices = crossvalind('Kfold',d,10);

for fold = 1:max(indices)
    % stratification
    % [Ytrain,dtrain,Ytest,dtest] = Bds_stratify(Yn,d,0.9);
    trainIdx = find(indices~=fold);
    testIdx = find(indices==fold);
    
    Ytrain = Yn(trainIdx,:);
    dtrain = d(trainIdx);
    Ytest = Yn(testIdx,:);
    dtest = d(testIdx);

    % dictionary
    D = Ytrain';

    % sparse coding

    nt = size(Ytest,1);
    ds = zeros(nt,1);

    sci = zeros(nt,1);

    for i=1:nt
        ytest = Ytest(i,:);

        switch options.mex
            case 'lasso'
                xt = full(mexLasso(ytest',D,param))';
            case 'omp'
                xt = full(mexOMP(ytest',D,param))';
        end


        e = zeros(c,1);
        s1 = sum(abs(xt));
        s = zeros(c,1);
        for k=1:c

            xtk = xt;

            ii  = dtrain ~= k;
            xtk(:,ii) = 0;
            s(k) = sum(abs(xtk));

            % clasificacion segun error de reconstruccion mas bajo
            Rk = (ytest'-D*xtk')';
            e(k) = sqrt(sum(Rk.*Rk,2));
        end
        sci(i) = (c*max(s)/s1-1)/(c-1);

        [me,j] = min(e);
        ds(i) = j;
    end

    pi = Bev_performance(ds,dtest);
    P(fold) = pi;
end
p = mean(P)*100;
fprintf('> performance SRC-Split 10 cross validation = %7.4f\n',p);

end