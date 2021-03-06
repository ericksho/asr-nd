function I = asr_bsif(I, n, b, desc)
%desc = 'im' for image or 'h' for histogram or 'nh' for normalized
%histogram
filename=['ICAtextureFilters_' int2str(n) 'x' int2str(n) '_' int2str(b) 'bit'];
load(filename, 'ICAtextureFilters');

% Three ways of using bsif.m :

% the image with grayvalues replaced by the BSIF bitstrings
bsifcodeim = bsif(I,ICAtextureFilters,desc);

I = bsifcodeim;

% unnormalized BSIF code word histogram
%bsifhist=bsif(img,ICAtextureFilters,'h');

% normalized BSIF code word histogram
%bsifhistnorm=bsif(img, ICAtextureFilters,'nh');

end