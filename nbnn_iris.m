options.feat = 'gray';  %tipo descriptor
options.nan_threshold = 0.1;

%% lectura de db
path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';
files = dir2(path);
N = numel(files);

dy = [ones(1,N/2) ones(1,N/2)*2]'; %1 hombres, 2 mujeres

for i = 1:numel(files)
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
s = 0.9; %testing percentage
count =1;

%% opciones
options.a = 16;     %ancho patch
options.b = 16;     %alto patch
options.m = 100;    %n de patches

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
options.desc = 0;

mex = 2;

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

%load asri_extracted.mat
%% separacion test de training
[Xt,dt,X,d] = Bds_stratify(Y,dy,s);

%% train
%% por cada imagen extraemos los patches
Xpatches = [];
dpatches = [];

if(options.show)
    bar = waitbar(0,'Train patches extraction');
end

N = size(X,1);
for i = 1:N
    if(options.show)
        waitbar(i/N,bar,['Train patches extraction...image: ' num2str(i)]);
    end
    I = reshape(X(i,:),options.h,options.w);
    [z, x] = asri_getPatches(I,options);
    
    if true %(strcmp(options.feat,'bsif'))
        for j=1:size(z,1)
            zp = z(j,:);
            if sum(zp==0)/numel(zp) < options.nan_threshold %porcentaje de zeros aceptados para agregar un patch
                p = reshape(zp,options.a,options.b);
                z2(j,:) = asr_bsif(p,15,11,'nh');
            end
        end
        z = z2; 
    end
    
    patches = asri_descriptor(z,x,options);
    
    Xpatches = [Xpatches' patches']';
    dpatches = [dpatches' ones(1,size(patches,1))*d(i)]';
end

if(options.show)
    close(bar);
end

%% buscamos un diccionario disjunto
% D1 = Xpatches(find(dpatches==1),:);
% D2 = Xpatches(find(dpatches==2),:);

[Xpatches,dpatches] = shiftReduceDictionary(Xpatches,dpatches,options);

% Xpatches = [D1' D2'];
%% test

ds = zeros(size(Xt,1),1);
ds2 = ds; 
N = size(Xt,1);
V = zeros(N,2);
V2 = zeros(N,2);

%% por cada imagen
if(options.show)
    bar = waitbar(0,'Train patches extraction');
end

for i = 539:N
    tic 
    I = reshape(Xt(i,:), options.h, options.w);
    v = zeros(options.n_class,1);
    v2 = v;
    
    [z, x] = asri_getPatches(I,options);
    
    if true %(strcmp(options.feat,'bsif'))
        for j=1:size(z,1)
            zp = z(j,:);
            if sum(zp==0)/numel(zp) < options.nan_threshold %porcentaje de zeros aceptados para agregar un patch
                p = reshape(zp,options.a,options.b);
                z2(j,:) = asr_bsif(p,15,11,'nh');
            end
        end
        z = z2;
    end
    
    patches = asri_descriptor(z,x,options);
    
    %% por cada patch
    for p = 1:size(patches,1)
        
        if(options.show)
            waitbar(i/N,bar,['Testing image: ' num2str(i) ' processing patch : ' num2str(p)]);
        end
        patch = patches(p,:);

        %% por cada clase
        D = Xpatches;
        dD = dpatches;

        %% calcular residuo y sci
        [R, sci] = asri_residual(D',patch, dD, options);

        %%%%%%%%%%%%%% pensar si filtramos el sci al votar como aca o
        %%%%%%%%%%%%%% si filtramos los votos que no cumplen con el sci

        %% filtrar por sci
        %idx = find(SCIC < options.sci);
        %R(idx) = 100;

        %% calcular el menor residuo 
        [~, idx] = min(R);
%         if sci ~= 1
%             if isnan(sci)
% %                pause
%             end
%             sci
%         end

        %% asignar voto usando el sci
        if sci > options.sci
            v(idx) = v(idx) + sci;
            v2(idx) = v2(idx) + 1;
        end
        %v(idx) = v(idx) + SCIC(idx);
        SCI(idx) = sci;

    end
    SCIT(i,:) = SCI;
    V(i,:) = v;
    V2(i,:) = v2;
    [~, idx] = max(v);
    [~, idx2] = max(v2);
    ds(i) = idx;
    ds2(i) = idx2;
    
    p = Bev_performance(ds(1:i),dt(1:i)); % performance on test data
    p2 = Bev_performance(ds2(1:i),dt(1:i)); % performance on test data
    t = toc;
    disp([i p p2 t])
end
        
if(options.show)
    close(bar);
end

%% evaluar
p = Bev_performance(ds,dt) % performance on test data
p2 = Bev_performance(ds2,dt) % performance on test data