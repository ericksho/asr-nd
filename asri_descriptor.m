% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_descriptor.m : Patch description
%
% (c) Domingo Mery - PUC (2013), ND (2014)
% modified by Erick Svec - ND (2014)

function patches = asri_descriptor(z,x,options)

method = options.desc;
alpha  = options.alpha;

switch method
    case 0
        patches = z;
    case 1
        patches  = Bft_uninorm([z alpha*x]);
    case 2
        patches = Bft_uninorm([Bft_uninorm(z) alpha*x]);
    case 3
        patches = [Bft_uninorm(z) alpha*x];

    case 4
        patches = [z alpha*x];
    case 5
        patches = [Bft_uninorm(z) alpha*x];
    otherwise
        error('Method %d does not exist in asr_descriptor.\n',method);
end
