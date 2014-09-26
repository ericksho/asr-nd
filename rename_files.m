%% rename files
clear
path = 'female-right-noglass/';
class = 2;

files = dir(path);

for i = 1:numel(files)
    if files(i).name(1) ~= '.'
        if i < 10
            d = '00000';
        else
            if i < 100
                d = '0000';
            else
                if i < 1000
                    d = '000';
                else
                    if i < 10000
                        d = '00';
                    else
                        if i < 100000
                            d = '0';
                        else
                            d = '';
                        end
                    end
                end
            end
        end

        id = [d num2str(i)];

        newName = ['reng_' num2str(class) '_' id '.tiff'];
        movefile([path files(i).name], [path newName]);
        I = imread([path newName]);
        try
            imshow(I,[]);
            pause(0.01);
        catch
        end
    end
end