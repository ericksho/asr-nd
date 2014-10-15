count = 1;

for w = 3:2:17
    for bits = 5:12
        for mex = 1:2
            try
                disp(['test with w: ' num2str(w) ' and bits: ' num2str(bits)])
                P(count) = src_test(w,bits,mex);
                param(count,:) = [w bits mex];
                count = count + 1;
            catch
                disp('failed')
            end
        end
    end
end

disp(P);