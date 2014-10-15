%% rename files
clear
path = '../datasets/iris_len/';

files = dir2(path);

class = 1;
for i = 1:numel(files)/2
    
    if i < 10
        d = '00';
    else
        if i < 100
            d = '0';
        else
            d = '';
        end
    end

    id = [d num2str(i)];
    

    newName = ['len_00' num2str(class) '_' id '.ppm'];
    movefile([path files(i).name], [path newName]);
    I = imread([path newName]);

    imshow(I,[]);
    pause(0.01);
end

class = 2;
for i1 = numel(files)/2+1:numel(files)
    i = i1-750;
    
    if i < 10
        d = '00';
    else
        if i < 100
            d = '0';
        else
            d = '';
        end
    end

    id = [d num2str(i)];
    

    newName = ['len_00' num2str(class) '_' id '.ppm'];
    movefile([path files(i1).name], [path newName]);
    I = imread([path newName]);

    imshow(I,[]);
    pause(0.01);
end