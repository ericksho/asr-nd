% count = 1;
% 
% for w = 9:2:17
%     for bits = 5:12
%         try
%             mex=2;
%             disp(['test with w: ' num2str(w) ' and bits: ' num2str(bits)])
%             P(count) = src_test(w,bits,mex);
%             Ps(count) = splitSrc_test(w,bits,mex);
%             param(count,:) = [w bits mex]';
%             count = count + 1;
%         catch
%             disp('failed')
%         end
%     end
% end
% 
% disp([P Ps]);


%%

count = 1;
load params.mat

for n_feats = 100:100:2000
    for lambda = 30:30%10:5:50
        for mode = 1:1%0:2
            options.n_feats = n_feats;
            options.first_blank = false;%first_blank-1;

            options.mex = 'lasso';
            params.lambda=lambda/100; % not more than 20 non-zeros coefficients
            params.numThreads=-1; % number of processors/cores to use; the default choice is -1
                                 % and uses all the cores of the machine
            params.mode=mode;        % penalized formulation
            options.param = params;

            disp(['test with  n_feats: ' num2str(n_feats) ' lambda: ' num2str(lambda) ' mode: ' num2str(mode)])
            [P(count), OUTPUT(count)] = srcSelection_test(options);
            
            %%%
            figure(1)
            pcv = zeros(count,1);
            for i = 1:count
                pcv(i) = mean(OUTPUT(i).P);
            end 
            plot(pcv(1:count))
            title('Mean accuracy vs Number of features 10 f-crossvalidation')
            figure(2)
            fstd = zeros(count,1);
            for i = 1:count
                fstd(i) = OUTPUT(i).sd;
            end
            plot(fstd);
            title('Sd vs Number of features 10 f-crossvalidation')
            %%%
            
            param(count,:) = [n_feats lambda mode]';
            count = count + 1;
        end
    end
end
save('results_left_mrmr_bsif_11x11_8_2');
disp([P]);