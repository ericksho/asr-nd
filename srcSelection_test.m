function [p,output] = srcSelection_test(options)
%
if false
    load feas_transf

    %Y = Y(:,fea_left_mrmr_bsif_11x11_8(1:options.n_feats));
    Ycv = Ycv(:,fea_left_mrmr_bsif_11x11_8(1:options.n_feats));
    Yv = Yv(:,fea_left_mrmr_bsif_11x11_8(1:options.n_feats));

    Ycv = normr(Ycv);
    Yv = normr(Yv);
else
        
    load feas

    N = 1500;

    d=(Labels==0)+1;

    Y = B3_total;

    [idxCv,idxV] = Bds_ixstratify(d,0.8);

    Ycv = Y(idxCv,:);
    dcv = d(idxCv);
    Yv = Y(idxV,:);
    dv = d(idxV);

    foldIdx = crossvalind('Kfold',dcv,10);
    
    Ycv = Ycv(:,fea_left_mrmr_bsif_11x11_8(1:options.n_feats));
    Yv = Yv(:,fea_left_mrmr_bsif_11x11_8(1:options.n_feats));

    Ycv = normr(Ycv);
    Yv = normr(Yv);
end

%% %%%%%%%%%%%%%%

c = 2;   % number of classes
param = options.param;
          
%% 10 k cross validation

%indices = crossvalind('Kfold',dcv,10); %ahora cargados para que sean
%siempre iguales

for fold = 1:max(foldIdx)
    % stratification
    % [Ytrain,dtrain,Ytest,dtest] = Bds_stratify(Yn,d,0.9);
    trainIdx = find(foldIdx~=fold);
    testIdx = find(foldIdx==fold);
    
    Ytrain = Ycv(trainIdx,:);
    dtrain = dcv(trainIdx);
    Ytest = Ycv(testIdx,:);
    dtest = dcv(testIdx);

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
    
    dsFold(fold,:) = ds;

    pi = Bev_performance(ds,dtest)*100;
    P(fold) = pi;
end
sd = std(P);
output.sd = sd;
output.P = P;
output.dsFold = dsFold;
output.options = options;
p = mean(P);
fprintf('> performance SRC 10 cross validation =       %7.4f\n',p);

%% validation

Ytrain = Ycv;
dtrain = dcv;
Ytest = Yv;
dtest = dv;

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

p = Bev_performance(ds,dtest)*100;

output.p = p;
output.ds = ds;

fprintf('> performance SRC validation set =            %7.4f\n\n',p);

end