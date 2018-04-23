%% Excercise 5.3 Fields of Experts
addpath('foe');
patch_size = 5;
load(['foe_' num2str(patch_size) 'x' num2str(patch_size) '.mat']);
Wb = basis' * W;
for i=1:size(Wb, 2)
    subplot(5, 5, i);
    imagesc(reshape(Wb(:,i), [sqrt(size(Wb, 1)) sqrt(size(Wb, 1))]));
    colormap(gray); axis off;
end

im = imread('street.png');
mask = logical(imread('street_mask.png'));

figure
imagesc(im);
figure
imagesc(mask);

painted_im = inpaint_foe(im, mask, basis, W, a);