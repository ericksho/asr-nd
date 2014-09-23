options.NV=350;
bsif.n = 3;
bsif.b = 8;
bsif.use = true;
options.bsif = bsif;

TT = [];
count = 1;
for n = 3:17
    for b = 5:12
        try
            T = asr_experiments(1,1,2,options);
            TT(count) = T;
            count = count + 1;
        catch
            %bla
        end
    end
end