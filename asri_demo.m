%% opciones
%options.w = 16;    %deprecated
options.a = 16;     %ancho patch
options.b = 16;     %alto patch
options.m = 300;    %n de patches

options.feat = 'gray';  %tipo descriptor
options.saliency = 0;   %distribucion de la extraccion de patches
options.border = 0;     %fijar bordes para no extraer parches
options.patchsub = 1;   %subsampling
options.uninorm = 1;    %normalization
options.show = 1;       %more like verbose
options.desc = 0;       %methos for descriptor mixes x and z
options.alpha = 0.2;    %alpha, weigth for x and z

options.kmeans_k = 20;	%kmeas father
options.knn_k = 30;     %nearest neigbors

options.h = 20;     %ancho de la imagen
options.w = 240;    %alto de la imagen

% parameter of the optimization procedure are chosen
param.L=10; % not more than 10 non-zeros coefficients
param.eps=0.1; % squared norm of the residual should be less than 0.1
param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                    % and uses all the cores of the machine

options.sparse_param = param;
options.sci = 0.8;
options.sci_method = 'sci'; %sci for normal or scii for each class

s = 0.9; %testing percentage

path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';
options.n_class = 2;

%% lectura de db
files = dir2(path);
N = numel(files);

dy = [ones(1,N/2) ones(1,N/2)*2]'; %1 hombres, 2 mujeres

%I = rgb2gray(imread([path '/' files(1).name]));
%[options.h, options.w] = size(I);

for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    Y(i,:) = I(:);
end
%%% saved in options.mat %%%
%% separacion test de training
[Xt,dt,X,d] = Bds_stratify(Y,dy,s);

%% train
[asri_trained] = asri_train(X,d, options);

%% test
[ds] = asri_test(Xt, asri_trained, options);

%% evaluar
p = Bev_performance(ds,dt) % performance on test data