%% Exercise 2.3 Panography
I1 = im2double(imread('bigsur1.jpg'));
I2 = im2double(imread('bigsur2.jpg'));

[frames1, descr1] = sift(rgb2gray(I1), 'Threshold', 0.03);
[frames2, descr2] = sift(rgb2gray(I2), 'Threshold', 0.03);

matches = siftmatch(descr1, descr2, 2.0);
% figure
% plotmatches(I1, I2, frames1(1:2, :), frames2(1:2, :),matches);

[~, n] = size(matches); % number of matches
translation = zeros(2, n);
for i = 1:n
    translation(:, i) = frames1(1:2, matches(1, i)) - frames2(1:2, matches(2, i));
end

mean_trans = mean(translation')';


% show_panography(I1, I2, translation, 'hard');
% show_panography(I1, I2, translation, 'soft');
% show_panography(I1, I2, mean_trans, 'hard');
% show_panography(I1, I2, translation, 'soft');

    J = [0, 1; 1, 0];
    left = zeros(2, 2);
    right = zeros(2, 1);
    for i = 1:n  
        right = right + J'*(J*translation(:, i));
        left = left + J*J';
    end
    left = inv(left);
    p = left*right; % tx ty
    
% show_panography(I1, I2, p, 'soft');

% RANSAC
inliers = matches;
best_err = inf;

for iter = 1:10
    
    [~, n] = size(inliers); % number of inliers
    translation = zeros(2, n);
    for i = 1:n
        translation(:, i) = frames1(1:2, inliers(1, i)) - frames2(1:2, inliers(2, i));
    end
    
    mean_trans = mean(translation')';

    % compute error of current model on the inliers
    x_dev = std(translation(1,:));
    y_dev = std(translation(2,:));
    err = x_dev + y_dev;
    
    % determine which observations are inliers
    new_inliers = [];
    for i = 1:n
        %new_err = sum(translation(:, i) - mean_trans);
        x_d = translation(1, i) - mean_trans(1, :);
        y_d = translation(2, i) - mean_trans(2, :);
        if ((x_d <= x_dev) && (y_d <= y_dev))
            new_inliers = [new_inliers, inliers(:, i)];
        end
    end
    
    inliers = new_inliers;
    
    % Store best model so far
    if (err < best_err)
        best_err = err;
        best_model = mean_trans;
    end
       
end


% show_panography(I1, I2,best_model ,'soft');
show_panography(I1, I2,best_model ,'hard');
