function [H, err] = find_homography(im1, im2)
%FIND_HOMOGRAPHY The functions finds a homography between two images
%
%   [H, err] = find_homography(im1, im2)
%
% The function finds a homography between two images based on SIFT feature
% points. The homography is found via a RANSAC-algorithm that iteratively
% runs a Levenberg-Marquardt algorithm (implemented in FIT_HOMOGRAPHY).
%


    warning off
    
    % Extract SIFT keypoints and descriptors
    if ndims(im1) == 3
        I1 = rgb2gray(im1);
    else
        I1 = im1;
    end
    if ndims(im2) == 3
        I2 = rgb2gray(im2);
    else 
        I2 = im2;
    end
    disp('Detecting SIFT feature points...');
    [points1, descr1] = sift(I1, 'Threshold', 0.05);
    [points2, descr2] = sift(I2, 'Threshold', 0.05);
    points1_x = points1(1,:);
    points1_y = points1(2,:);
    points2_x = points2(1,:);
    points2_y = points2(2,:);
    
    % Perform matching of SIFT keypoints
    disp(['Matching ' num2str(size(points1, 2) + size(points2, 2)) ' SIFT feature points...']);
    descr1 = uint8(512 * descr1);
	descr2 = uint8(512 * descr2);
	matches = siftmatch(descr1, descr2, 5);
%     plotmatches(I1, I2, points1(1:2,:), points2(1:2,:), matches); pause

    % Perform fitting using RANSAC
    max_outer_iter = 20;
    max_inner_iter = 50;
    best_err = Inf;
    best_inliers = [];
    for outer_iter=1:max_outer_iter
        
        % Randomly initialize inliers
        inliers = rand(1, length(matches)) > .5;    
        
        % Run RANSAC iterations
        for iter=1:max_inner_iter
            
            % Check whether we have sufficient inliers
            if ~rem(iter, 10)
                disp(['RANSAC run ' num2str(outer_iter) ', iteration ' num2str(iter) ' (' num2str(sum(inliers)) ' inliers; best error = ' num2str(best_err) ')...']);
            end
            if sum(inliers) < 8
                inliers = rand(1, length(matches)) > .5;
            end

            % Fit homography based on current inliers
            [H, err] = fit_homography(points1_x, points1_y, points2_x, points2_y, matches(:,inliers));

            % Store best model until now
            if sum(err(:)) / sum(inliers) < best_err
                best_inliers = inliers;
                best_err = sum(err(:)) ./ sum(inliers);
            end

            % Compute locations of points according to current homography
            x = points1_x(matches(1,:));
            y = points1_y(matches(1,:));
            xi_prime = H' * [x; y; ones(1, numel(x))];
            x_prime = xi_prime(1,:) ./ xi_prime(3,:);
            y_prime = xi_prime(2,:) ./ xi_prime(3,:);

            % Compute residuals
            residuals = [points2_x(matches(2,:)) - x_prime; ...
                         points2_y(matches(2,:)) - y_prime];
            err = sum(residuals .^ 2, 1);

            % Update set of inliers
            inliers = abs(err - mean(err)) < .2 * std(err);
        end 
    end
    
    % Perform final fit
    [H, err] = fit_homography(points1_x, points1_y, points2_x, points2_y, matches(:,best_inliers), 500);
%     plotmatches(I1, I2, points1(1:2,:), points2(1:2,:), matches(:,best_inliers)); pause
    