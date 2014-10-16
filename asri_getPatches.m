function [z, x] = asri_getPatches(I, options)

a     = options.a;
b     = options.b;
m     = options.m;
border = options.border;

[h,w] = size(I);

U = asr_LUTpatches(h,w,a,b);

switch options.feat
    case 'gray'
        z = zeros(m,a*b);
end
x = zeros(m,2);


switch options.saliency
    case 0 % anywhere
        ii        = border+randi(h-a+1-2*border,m,1);
        jj        = border+randi(w-b+1-2*border,m,1);
    case 1 % salient regions
        [~,J_off] = Bim_cssalient(I,1,0);
        R_off     = J_off>0;
        mm = 10*m;
        ii        = border+randi(h-a+1-2*border,mm,1);
        jj        = border+randi(w-b+1-2*border,mm,1);
        [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
        im        = randi(length(ii),m,1);
        ii        = ii(im)-round(border+a/2);
        jj        = jj(im)-round(border+b/2);
    case 2 % edges
        J_off     = edge(I,'canny',0.1,1);
        R_off     = imdilate(J_off,ones(7,7));
        mm        = 10*m;
        ii        = border+randi(h-a+1-2*border,mm,1);
        jj        = border+randi(w-b+1-2*border,mm,1);
        [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
        im        = randi(length(ii),m,1);
        ii        = ii(im)-round(border+a/2);
        jj        = jj(im)-round(border+b/2);
    case 3 % no specular regions
        R_off     = I0<245;
        mm        = 10*m;
        ii        = border+randi(h-a+1-2*border,mm,1);
        jj        = border+randi(w-b+1-2*border,mm,1);
        [ii,jj]   = andR(ii+round(border+a/2),jj+round(border+b/2),R_off);
        im        = randi(length(ii),m,1);
        ii        = ii(im)-round(border+a/2);
        jj        = jj(im)-round(border+b/2);
end

z         = asr_readpatches(I,ii,jj,U,options);
x         = [ii jj];


x = x+ones(m,1)/2*[a b];
%x(:,1) = x(:,1)/h;
%x(:,2) = x(:,2)/w;

if options.uninorm == 1 % normalization
    %z         = Bft_uninorm(z); %%% esta entregando muchos nan
    z         = normr(z); %%% esta entregando muchos nan
    x         = [x(:,1)/a x(:,2)/b];
end

end