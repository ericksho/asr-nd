function [Y] = featuresExtractor(w,bits,mode,path)
%
% metodo de Robust Face Recognition via Sparse Representation - Wright (PAMI 2007)
% probado en la base de datos de de Iris
% validacion: stratified hold out (90% training 10% testing)

files = dir2(path);

N = numel(files);
%class = 0; %0 hombre, 1 mujer

dall = [zeros(1,N/2) ones(1,N/2)]';

filename=['ICAtextureFilters_' int2str(w) 'x' int2str(w) '_' int2str(bits) 'bit'];
load(filename, 'ICAtextureFilters');

for i = 1:numel(files)
    I = rgb2gray(imread([path '/' files(i).name]));
    I = I(2:11,:);
    %BSIF
    I = bsif(I,ICAtextureFilters,mode); %'im' for grayscale, 'h'); for histogram and 'nh'); for normalized histogram
    if(~strcmp(mode,'im'))
        I(1) = 0;
    end
    I = I/norm(I);
    Y(i,:) = I(:);
end


% normalization
Yn = zeros(size(Y));
for i=1:N
    Yn(i,:) = Y(i,:)/norm(Y(i,:));
end

d = dall+1;
end