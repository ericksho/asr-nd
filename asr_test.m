bsif.n = 11;
bsif.b = 10;
bsif.use = false;
options.bsif = bsif;

T = [];
count = 1;

for k = 1:1
    for i = 1:1
        for j = 3:3
            for l = 1:3
                %%%%%%%%%
                options.show         = 0;       % display results: 0 Nathing, 1 Messages, 2 Bars, 3 Images
                options.Q            = 32;      % number of parent clusters
                options.R            = 20;      % number of child clusters

                options.stoplist     = 1;       % 1/0 includes / does not include stop list
                options.w            = 16;      % pacth size (w*w) pixels

                options.scqth        = 0.1;     % threshold for selected patches by testing
                options.top_bound    = 0.05*j;    % 5%   top    : most frequent word to be stopped ****
                options.bottom_bound = 0.1;     % 10%  bottom : less frequent word to be stopped
                options.NV           = 200;     % number of visual words of visual vocabulary

                options.stopth       = 0.9*1/l;     % words that are very different from dictionary are eliminates ***


                %%%%%%%%%

                p = asr_experiments(1,1,2,options);
                disp([p i j k l]);
                
                T(count,:) = [p i j k l]; %1 3 1 3 
                count = count +1;
            end
        end
    end
end