options.feat = 'gray';  %tipo descriptor

%% lectura de db
%path = '/Users/ericksho/Documents/datasets/Left_eye_Normalized/';
path = '/Users/esvecpar/Documents/datasets/GFI_database/Left_eye_Normalized/';

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
    if(sum(isnan(I(:))) > 0)
        pause
    end
    Y(i,:) = I(:);
end
Yv = Y(N*0.8+1:N,:);
dv = dy(N*0.8+1:N);

Ycv = Y(1:N*0.8,:);
dcv = dy(1:N*0.8);

%%
main_count = 1;
for m = 100:100:500
    for a = 5:5:20
        for b = 5:5:100
            for bsif_w = 3:2:17
                last_bits = 12;
                if bsif_w == 3
                    last_bits = 8;
                end
                for bsif_bits = 5:last_bits

                    %% opciones
                    options.use_bsif = true;
                    options.bsif_w = bsif_w;
                    options.bsif_bits = bsif_bits;

                    options.a = a;     %ancho patch
                    options.b = b;     %alto patch
                    options.m = m;    %n de patches


                    options.saliency = 0;   %distribucion de la extraccion de patches
                    options.border = 0;     %fijar bordes para no extraer parches
                    options.patchsub = 1;   %subsampling
                    options.uninorm = 1;    %normalization
                    options.show = 1;
                    options.alpha = 0.5;

                    knn_options.k = 1;
                    options.knn_options = knn_options;     %nearest neigbors

                    options.h = 20;     %ancho de la imagen
                    options.w = 240;    %alto de la imagen
                    options.desc = 0;

                    options.mex = 'lasso';
                    param.lambda=0.15; % not more than 20 non-zeros coefficients
                    param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                                         % and uses all the cores of the machine
                    param.mode=2;        % penalized formulation

                    options.sparse_param = param;
                    options.sci = 0.8;

                    options.n_class = 2;
                    options.nan_threshold = 0.1;

                    s = 0.1; %testing percentage
                    %% separacion test de training
                    %[Xt,dt,X,d] = Bds_stratify(Ycv,dcv,s);
                    
                    indices = crossvalind('Kfold',dcv,10);
                    fold_count = 1;
                    for fold = 1:max(indices)
                        trainIdx = find(indices~=fold);
                        testIdx = find(indices==fold);

                        X = Ycv(trainIdx,:);
                        d = dcv(trainIdx);
                        Xt = Ycv(testIdx,:);
                        dt = dcv(testIdx);

                        %% train
                        %% por cada imagen extraemos los patches
                        if(options.show)
                            bar = waitbar(0,'Train patches extraction');
                        end

                        N = size(X,1);
                        
                        I = reshape(X(1,:),options.h,options.w);
                        [z, x] = asri_getPatches(I,options);
                        zp = z(1,:);
                        p = reshape(zp,options.a,options.b);
                        z2 = asr_bsif(p,options.bsif_w,options.bsif_bits,'nh');
                        z2size = size(z2,2);
                        
                        if options.use_bsif
                            Xpatches = zeros(N*options.m,z2size);
                            z2 = zeros(options.m,z2size);
                        else
                            Xpatches = zeros(N*options.m,options.a*options.b);
                            z2 = zeros(options.m,options.a*options.b);
                        end
                        dpatches = zeros(N*options.m,1);

                        count = 1;
                        for i = 1:N
                            if(options.show)
                                waitbar(i/N,bar,['Train patches extraction...image: ' num2str(i)]);
                            end
                            I = reshape(X(i,:),options.h,options.w);
                            [z, x] = asri_getPatches(I,options);
                            dz2 = zeros(options.m,1);

                            if options.use_bsif
                                for j=1:size(z,1)
                                    zp = z(j,:);
                                    if sum(zp==0)/numel(zp) < options.nan_threshold && sum(isnan(zp)) == 0 %porcentaje de zeros aceptados para agregar un patch
                                       p = reshape(zp,options.a,options.b);
                                       z2(j,:) = asr_bsif(p,options.bsif_w,options.bsif_bits,'nh');
                                       dz2(j) = 1;
                                    end
                                end
                                idx = find(dz2==1);
                                z = z2(idx,:);
                                x = x(idx,:);
                            end

                            patches = asri_descriptor(z,x,options);

                            Xpatches(count:count+size(patches,1)-1,:) = patches;
                            dpatches(count:count+size(patches,1)-1) = ones(size(patches,1),1)*d(i);
                            count = count + size(patches,1);
                        end

                        Xpatches = Xpatches(1:count-1,:);
                        dpatches = dpatches(1:count-1);

                        if(options.show)
                            close(bar);
                        end

                        %% entrenamos un knn

                        options.knn_op = Bcl_knn(Xpatches,dpatches,options.knn_options);
                        disp('knn trained');

                        %% buscamos un diccionario disjunto
                        % D1 = Xpatches(find(dpatches==1),:);
                        % D2 = Xpatches(find(dpatches==2),:);

                        %%hacer algo aqui para reducir el diccionario de manera inteligente

                        % Xpatches = [D1' D2'];
                        %% test

                        ds = zeros(size(Xt,1),1);
                        ds2 = zeros(size(Xt,1),options.knn_op.k);
                        N = size(Xt,1);
                        V = zeros(N,2);
                        V2 = zeros(N,2);

                        %% por cada imagen
                        if(options.show)
                            bar = waitbar(0,'Train patches extraction');
                        end

                        for i = 1:N
                            tic 

                            if(options.show)
                                waitbar(i/N,bar,['Testing image: ' num2str(i)]);
                            end

                            I = reshape(Xt(i,:), options.h, options.w);
                            v = zeros(options.n_class,1);
                            v2 = v;

                            [z, x] = asri_getPatches(I,options);
                            dz2 = zeros(options.m,1);

                            if options.use_bsif
                                for j=1:size(z,1)
                                    zp = z(j,:);
                                    if sum(zp==0)/numel(zp) < options.nan_threshold  && sum(isnan(zp)) == 0 %porcentaje de zeros aceptados para agregar un patch
                                        p = reshape(zp,options.a,options.b);
                                        z2(j,:) = asr_bsif(p,options.bsif_w,options.bsif_bits,'nh');
                                        dz2(j) = 1;
                                    end
                                end
                                idx = find(dz2==1);
                                z = z2(idx,:);
                                x = x(idx,:);
                            end

                            patches = asri_descriptor(z,x,options);

                            %v = Bcl_knn(patches,options.knn_op);

                            [idx,dist] = vl_kdtreequery(options.knn_op.kdtree,options.knn_op.X',patches','NumNeighbors',options.knn_op.k);
                            dd = options.knn_op.d(idx);
                            v = mode(dd)';

                            pv = zeros(size(v));

                            for c = 1:size(v)
                                pv(c) = sum(dd(:,c)==v(c));
                            end

                            ds(i) = mode(v);
                            %ds2(i,:) = pv;
                        %     
                        %     
                        %     %% por cada patch
                        %     for p = 1:size(patches,1)
                        %         
                        %         patch = patches(p,:);
                        %         
                        %         v(idx) = v(idx) + sci;
                        %         v2(idx) = v2(idx) + 1;
                        %         
                        %         %v(idx) = v(idx) + SCIC(idx);
                        %         SCI(idx) = sci;
                        % 
                        %     end
                        %     
                        %     V(i,:) = v;
                        %     V2(i,:) = v2;
                        %     [~, idx] = max(v);
                        %     [~, idx2] = max(v2);
                        %     ds(i) = idx;
                        %     ds2(i) = idx2;

                            %p = Bev_performance(ds(1:i),dt(1:i)); % performance on test data
                            %p2 = Bev_performance(ds2(1:i),dt(1:i)); % performance on test data
                            T(i) = toc;
                            %disp([i p T(i)])
                        end

                        if(options.show)
                            close(bar);
                        end

                        %% evaluar
                        p = Bev_performance(ds,dt) % performance on test data
                        FP(fold) = p;
                        FT(fold) = mean(T);
                    end
                    
                    fp = mean(FP);
                    PP(main_count) = fp;
                    ft = mean(FT);
                    TT(main_count) = ft;
                    
                    disp(['accuracy: ' num2str(fp) ' time: ' num2str(ft) ' main count: ' num2str(main_count)])
                    
                    save(['p: ' num2str(fp) '.mat'], 'fp', 'ft', 'options');
                    
                    main_count = main_count+1;
                end
            end
        end
    end
end