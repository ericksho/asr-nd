function [Xs, ds] = zigzagset(X,d)

ds(1:2:numel(d)) = d(1:numel(d)/2); 
ds(2:2:numel(d)) = d(numel(d)/2+1:numel(d));
Xs(1:2:numel(d),:) = X(1:numel(d)/2,:); 
Xs(2:2:numel(d),:) = X(numel(d)/2+1:numel(d),:);

end