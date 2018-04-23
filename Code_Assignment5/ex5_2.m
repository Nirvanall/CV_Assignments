%% Exercise 5.2 Graph cuts
addpath('maxflow');
im = imread('image.png');
im = rgb2gray(im);
[h, w] = size(im);
[val, ~, im] = unique(im);
im = reshape(im, [h w]);
im(im ==2) = -1;
true_im = im;

figure
imagesc(true_im);

mask = (rand(size(im)) > .9);
im(mask) = -im(mask);
noisy_im = im;

figure
imagesc(noisy_im);

eta = .1;
alpha = -.05;
beta = .2;

E = edges4connected(h, w);

N = h * w;
V = repmat(beta, [size(E, 1) 1]);
A = sparse(E(:,1), E(:,2), V, N, N, 4 * N);

T = [-1*ones(h*w, 1).*noisy_im(:), ones(h*w, 1).*noisy_im(:)];
T = sparse(T);

[~, im] = maxflow(A, T);
im(im == 0) = -1;
im = reshape(double(im), [h w]);

err = 0.5*sum(sum(abs(true_im - im)))/(h*w);

figure
imagesc(im);

