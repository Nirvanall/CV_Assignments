function h = color_histogram(patch)
%COLOR_HISTOGRAM Computes a color histogram for an image patch
%
%   h = color_histogram(patch)
%
% Given an RGB image patch, the function computes a color histogram.


    patch = double(patch);
    R = patch(:,:,1);
    G = patch(:,:,2);
    B = patch(:,:,3);
    h = [hist(R(:), 32) hist(G(:), 32) hist(B(:), 32)]; 
    h = h ./ sum(h);
