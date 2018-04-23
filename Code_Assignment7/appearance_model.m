function L = appearance_model(s_t, I, colorModel, VIDEO_WIDTH, VIDEO_HEIGHT)
%APPEARANCE_MODEL Implementation of a simple appearance model
%
%   L = appearance_model(s_t, I, colorModel, VIDEO_WIDTH, VIDEO_HEIGHT)
%
% This function computes the likelihood that data observed in the
% image I (L) supports the state estimated by s_t.  I computed the
% likelihood by comparing a color histogram extracted from the bounding box
% defined by s_to to a known color model which I extracted beforehand. I
% modeled L = p(z_t|s_t) \propto exp(-lambda * dist(h, colormodel)) where dist
% is the KL divergence of two histograms, h is a color histogram
% corresponding to s_t, colorModel is a known color model, and lambda is a
% hyperparameter used to adjust the pickiness of the likelihood function.
% You may, however, use any likelihood model you prefer.


    % Extract the image patch corresponding to the current particle
    r = round(s_t(2)); 
    c = round(s_t(1));
    w = round(s_t(5) * s_t(6)); 
    h = round(s_t(6));
    r2 = min(VIDEO_HEIGHT, r + h + 1);
    c2 = min(VIDEO_WIDTH,  c + w + 1);
    patch = I(r:r2,c:c2,:);

    % TODO: Compute the appearance likelihood z_t here
    h = color_histogram(patch);
    d = kl_divergence(h, colorModel);
    lambda = 10;
    L = exp(-lambda*d);
    % ...
end
