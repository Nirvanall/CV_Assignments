%% Exercise 6.2 Dalal-Triggs detection
addpath('minFunc');
block_size = 8;
im = im2double(imread('images/positive/crop_000010a.png'));
features = hog(im, block_size);
figure
imshow(visualizeHOG(features));
%%
pos_folder = 'images/positive/';
neg_folder = 'images/negative/';
pos_files = dir([pos_folder '*.png']);
neg_files = dir([neg_folder '*.png']);
[A, hog_size] = load_hog_images(pos_folder, pos_files, ...
    neg_folder, neg_files, block_size);

lambda = 0.1;
W = loglc2(A, lambda);
err = prcrossval(A, loglc2([], lambda), 5);
%%
figure
imshow(visualizeHOG(reshape(W.data.E(:,2), hog_size)));

% Loop over test images
test_files = dir('images/test/*.png');
for j = 1:length(test_files)
    % load image
    im = im2double(imread(['images/test/' test_files(j).name]));
    [boxes, response] = sliding_window_detector(im, W, block_size, hog_size);
    % plot results
    subplot(1,2,1); imagesc(response, [0 1]);
    colormap jet; axis equal tight off;
    subplot(1,2,2); imshow(im); hold on
    for i = 1:size(boxes, 1)
        rectangle('Position', [boxes(i, 2)   boxes(i, 1) ...
                                  boxes(i, 4) - boxes(i, 2) ...
                                  boxes(i, 3) - boxes(i, 1)], ...
                            'LineWidth', 2, 'EdgeColor', [1 0 0]);
    end
    hold off; pause
end
