currentDate = date;
save('features_cropped_left.mat','currentDate');
for eye = 1:2
    
    if eye == 1
        eyet = 'Left';
    else
        eyet = 'Right';
    end
    path = ['/Users/esvecpar/Documents/datasets/GFI_database/' eyet '_eye_Normalized/'];
    for w = 3:2:17
        for bits = 5:12
            for m = 1:3
                try
                    switch m
                        case 1
                            mode = 'im';
                        case 2
                            mode = 'h';
                        case 3 
                            mode = 'nh';
                    end
                    disp(['Features from ' eyet ' eye with w: ' num2str(w) ' and bits: ' num2str(bits) ' and extracting: ' mode])
                    eval(['Y_left_bsif_' num2str(w) 'x' num2str(w) '_' num2str(bits) '= featuresExtractor(w,bits,mode,path);']);
                    save('features_cropped_left.mat',['Y_left_bsif_' num2str(w) 'x' num2str(w) '_' num2str(bits)],'-append');
                catch
                    disp('failed')
                end
            end
        end
    end
end