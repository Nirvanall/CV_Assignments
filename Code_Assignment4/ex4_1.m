%% Exercise 4.1 Eigenfaces
cd('eigenface');
cd('images');
files = dir('*.tiff');
% Load all the images
x = imread(files(1).name);
x = x(1:end);
X = zeros(length(files), length(x));
X(1, :) = x;
for i = 2:length(files)
    x = imread(files(i).name);
    x = x(1:end);
    X(i, :) = x;
end
cd('..');
cd('..');
[V, D] = eig(cov(X));
save eigen V D;
%% 
load eigen
[lambda, index] = sort(diag(D), 'descend');
lambda = lambda/sum(lambda);

PC = []; % principal component

percent = 0;
j = 1;
while percent < 0.9
    PC = [PC, V(:, length(x)+1-j)];
    percent = percent + lambda(j);
    j = j + 1;    
end

figure;clf;
ncols = 5;
nrows = ceil((j-1)/ncols);
for i = 1: (j-1)
    subplot(nrows, ncols, i);
    imagesc(reshape(PC(:,i), [64 64])); 
    axis off equal tight; 
    colormap gray;
end





