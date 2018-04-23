function [H, err] = fit_homography(points1_x, points1_y, points2_x, points2_y, matches, max_iter)
%FIT_HOMOGRAPHY Fit homography using Levenberg-Marquardt algorithm
%
%   [H, err] = fit_homography(points1_x, points1_y, points2_x, points2_y, matches, max_iter)
%
% The function fits a homography between two sets of points and
% correspondeces between them (in matches), by solving the non-linear least
% squares problem via the Levenberg-Marquardt algorithm.
%
% The maximum number of iterations is optional (default = 30).


    if ~exist('max_iter', 'var') || isempty(max_iter)
        max_iter = 30;
    end

    % Initialize the homography
    A = zeros(2 * size(matches, 2), 8);
    b = zeros(2 * size(matches, 2), 1);
    for i=1:size(matches, 2)
        x       = points1_x(matches(1, i));
        y       = points1_y(matches(1, i)); 
        x_prime = points2_x(matches(2, i));
        y_prime = points2_y(matches(2, i)); 
        A((i - 1) * 2 + 1:i * 2,:) = [x y 1 0 0 0 -x_prime .* x -x_prime .* y; ...
                                      0 0 0 x y 1 -y_prime .* x -y_prime .* y];
        b((i - 1) * 2 + 1:i * 2) = [x_prime - x; ...
                                    y_prime - y];
    end
    tmp = A \ b;
    H = ones(3, 3);
    H(1:8) = tmp';
   
    % Perform iterative least-squares to find homography
    best_C = Inf;
    best_H = [];
    best_err = [];
    for iter=1:max_iter
        
        % Compute locations of points according to current homography
        x = points1_x(matches(1,:));
        y = points1_y(matches(1,:));
        % APPLY HOMOGRAPHY H' TO POINTS X AND Y HERE, AND MAKE SURE THE
        % RESULTS IS STORED IN CARTESIAN COORDINATES. STORE THE CARTESIAN
        % COORDINATES IN X_PRIME AND Y_PRIME. STORE THE NORMALIZING WEIGHTS
        % OF THE HOMOGENEOUS COORDINATES IN A ROW VECTOR CALLED Z.
         xi_prime = H' * [x; y; ones(1, numel(x))];
         x_prime = xi_prime(1,:) ./ xi_prime(3,:);
         y_prime = xi_prime(2,:) ./ xi_prime(3,:);
         %Z = xi_prime(3,:)/norm(xi_prime(3,:));
         Z = xi_prime(3,:);
                              
        % Compute residuals
        residuals = [points2_x(matches(2,:)) - x_prime; ...
                     points2_y(matches(2,:)) - y_prime];

        % Compute approximation to the Hessian
        J1 = bsxfun(@rdivide, [x' y' ones(numel(x), 1) zeros(numel(x), 1) zeros(numel(x), 1) zeros(numel(x), 1) -x_prime' .* x' -x_prime' .* y'], Z'); 
        J2 = bsxfun(@rdivide, [zeros(numel(x), 1) zeros(numel(x), 1) zeros(numel(x), 1) x' y' ones(numel(x), 1) -y_prime' .* x' -y_prime' .* y'], Z'); 
        A = J1' * J1 + J2' * J2;
        
        % Compute product of Jacobian and residuals
        Jr = J1' * residuals(1,:)' + ...
             J2' * residuals(2,:)';
        
        % Compute parameter update
        lambda = 0.01;
        delta_H = (A + lambda .* diag(diag(A))) \ Jr;
        H(1:8) = H(1:8) + delta_H';
        
        % Monitor progress
        err = sum(residuals .^ 2, 1);
        C = sum(err(:)) / numel(err);
        if C < best_C
            best_C = C;
            best_H = H;
            best_err = err;
        end
    end
    H = best_H;
    err = best_err;
    