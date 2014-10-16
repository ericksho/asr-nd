
path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';

%% lectura de db
files = dir2(path);
N = numel(files);

dy = [ones(1,N/2) ones(1,N/2)*2]'; %1 hombres, 2 mujeres

for i = 1:N
    Irgb = imread([path '/' files(i).name]);
    I = rgb2gray(Irgb);
    [ix, iy,~] = size(Irgb);
    for x = 1:ix
        for y = 1:iy
            if Irgb(x,y,1) == 200 && Irgb(x,y,2) == 200 && Irgb(x,y,3) == 0
                I(x,y) = 0;
            end
        end
    end
    Y(i,:) = I(:);
end

Yv = Y(N*0.8+1:N,:);
dv = dy(N*0.8+1:N);

Ycv = Y(1:N*0.8,:);
dcv = dy(1:N*0.8);

s = 0.9; %testing percentage
count =1;

%%
kmeans_k = 10;
knn_k = 30;
m = 400;
a = 5;
b = 10;
mex = 2;

%%

for kmeans_k = 10:10:30
    for knn_k = 20:10:40
        for m = 100:100:500
            for a = 5:5:20
                for b = 10:5:50

                        %% opciones
                        options.nan_threshold = 0.1;
                        
                        %options.w = 16;    %deprecated
                        options.a = a;     %ancho patch
                        options.b = b;     %alto patch
                        options.m = m;    %n de patches

                        options.feat = 'gray';  %tipo descriptor
                        options.saliency = 0;   %distribucion de la extraccion de patches
                        options.border = 0;     %fijar bordes para no extraer parches
                        options.patchsub = 1;   %subsampling
                        options.uninorm = 1;    %normalization
                        options.show = 1;
                        options.alpha = 0.5;

                        options.kmeans_k = 20;	%kmeas father
                        options.knn_k = 30;     %nearest neigbors

                        options.h = 20;     %ancho de la imagen
                        options.w = 240;    %alto de la imagen
                        options.desc = 5;
                        
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
                        
                        options.sparse_param = param;
                        options.sci = 0.8;

                        options.n_class = 2;
                        
                        %%
                        disp(['kmeans_k: ' num2str(kmeans_k) ' knn_k: ' num2str(knn_k) ' m: ' num2str(m) ' a: ' num2str(a) ' b: ' num2str(b) ' mex: ' options.mex])
                        s=0.1;

                        %% separacion test de training
                        [Xt,dt,X,d] = Bds_stratify(Ycv,dcv,s);
                        
                        [Xt,dt] = zigzagset(Xt,dt);

                        %% train
                        [asri_trained] = asri_train(X,d, options);

                        %% test
                        [ds] = asri_test(Xt, asri_trained, options);

                        %% evaluar
                        p = Bev_performance(ds,dt') % performance on test data
                        
                        P(count,:) = [p kmeans_k knn_k m a b mex];
                        DS(count,:) = ds;
                        count = count+1;
                        save(['kmeans_k' num2str(kmeans_k) 'knn_k' num2str(knn_k) 'm' num2str(m) 'a' num2str(a) 'b' num2str(b) 'mex' options.mex '.mat'], 'asri_trained', 'ds', 'Xt','dt','X','d','options')
                        
                        %para ahorrar memoria
                        clearvars -except P kmeans_k knn_k m a b mex Y dy s count Ycv dcv
                end
            end
        end
    end
end

save('P.mat', P)