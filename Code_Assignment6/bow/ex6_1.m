%% Exercise 6.1 Bag of visual words
folders = dir('images/*');
label_count = 0;
labels = zeros(0);
image_list = cell(0);
for i = 1:length(folders)
    if folders(i).name(1) ~= '.'
        label_count = label_count + 1;
        images = dir(['images/' folders(i).name '/*.jpg']);
        for j = 1:length(images)
            image_list{end + 1} = ['images/' folders(i).name '/' images(j).name];
            labels(end + 1) = label_count;
        end       
    end
end

patches_per_image = 100;
patch_size = 9;
patches = extract_random_patches(image_list, patches_per_image, patch_size);

K = 512;
codebook = kmeans(patches, K);
K = size(codebook, 2);
figure
visualize_codebook(codebook);
%% extract the bag-of-visual-word feature vector
X= zeros(length(image_list), K);
for k = 1:length(image_list)
    k
    im = imread(image_list{k});
    if ~ismatrix(im)
    im = rgb2gray(im);
    end
    im = double(im) ./ 255;
    im_patches = im2col(im, [patch_size patch_size], 'sliding');

    [~, N] = size(im_patches);
%     D = zeros(N,K); % distance matrix
%     for i = 1: N
%         for j = 1:K
%             D(i,j) = im_patches(:,i)'*im_patches(:,i)+codebook(:,j)'*codebook(:,j)-2*im_patches(:,i)'*codebook(:,j);      
%         end
%     end
    D = pdist2(im_patches', codebook');
    
    [~, assignment] = min(D, [], 2);
    feat = accumarray([ones(numel(assignment), 1) assignment], ones(numel(assignment), 1), [1 K]);
    feat = feat ./ sum(feat);
    X(k, :) = feat;
end

addpath(genpath('minFunc'));
A = prdataset(X, labels');
err = prcrossval(A, loglc2, 10);


% D2 = zeros(length(image_list), length(image_list));
% for i = 1:length(image_list)
%     for j = 1:length(image_list)
%         D2(i,j) = X(:,i)'*X(:,i)+X(:,j)'*X(:,j)-2*X(:,i)'*X(:,j);
%     end
% end
D2 = pdist2(X, X); 
D2 = D2.^2;
D2 = D2 + diag(100*ones(1,250));

%[M, I] = min(D2);
[~, assignment2] = min(D2, [], 2);
figure
subplot(1, 2, 1); imshow(imread(image_list{3})); 
subplot(1, 2, 2); imshow(imread(image_list{assignment2(3)}));

