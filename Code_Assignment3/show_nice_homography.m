function trans_im = show_nice_homography(im1, im2, H, method)
%SHOW_NICE_HOMOGRAPHY Show homography using seamn finding, blending, etc..
%
%   trans_im = show_nice_homography(im1, im2, H, method)
%
% Given two images im1 and im2 and a homography H between the two images,
% the methods stitches the two images. It finds the optimal seam between
% the two images using a graph-cut algorithm, and can correct for exposure
% differences by employing the seam in the gradient domain.
%
% Possible values for method are 'simple', 'feather', and 'gradient'.


    % Apply homogeneous transform on image 2 to figure out its size
    tform = maketform('projective', H);
    [~, xdata, ydata] = imtransform(im2, tform, 'bicubic');
    
    % Figure out size of the merged image
    ydataout = [min(1, floor(ydata(1))) max(max(size(im1, 1), size(im2, 1)), ceil(ydata(2)))];
    xdataout = [min(1, floor(xdata(1))) max(max(size(im1, 1), size(im1, 2)), ceil(xdata(2)))];
    
    % Transform both images into the merged image
    im1t = imtransform(im1, maketform('affine', eye(3)), 'XData', xdataout, 'YData', ydataout);
    im2t = imtransform(im2, tform,                       'XData', xdataout, 'YData', ydataout);
    if any(size(im1t) ~= size(im2t))                                        % this is a dirty hack!
        im2t = imresize(im2t, [size(im1t, 1) size(im1t, 2)], 'bicubic');
    end
    im1t = padarray(im1t, [1 1 0]);
    im2t = padarray(im2t, [1 1 0]);
    
    % Determine mask in which the seam should be found
    [r, c] = find(all(im1t ~= 0, 3) & all(im2t ~= 0, 3));
    min_r = min(r) - 1; max_r = max(r) + 1;
    min_c = min(c) - 1; max_c = max(c) + 1;    
    im1t_r = double(im1t(min_r:max_r, min_c:max_c, 1));
    im1t_g = double(im1t(min_r:max_r, min_c:max_c, 2));
    im1t_b = double(im1t(min_r:max_r, min_c:max_c, 3));
    im2t_r = double(im2t(min_r:max_r, min_c:max_c, 1));
    im2t_g = double(im2t(min_r:max_r, min_c:max_c, 2));
    im2t_b = double(im2t(min_r:max_r, min_c:max_c, 3));
    [height, width] = size(im1t_r);
    
    % Construct graph
    N = height * width;
    E = edges4connected(height, width);
    V = abs(im1t_r(E(:,1)) - im2t_r(E(:,2))) + ...
        abs(im1t_g(E(:,1)) - im2t_g(E(:,2))) + ...
        abs(im1t_b(E(:,1)) - im2t_b(E(:,2))) + eps;  % why not also the reverse?
    A = sparse(E(:,1), E(:,2), V, N, N, 4 * N);
    
    % Set terminal weights (if only one image available, use that)    
    ind1 = find(bwmorph(im1t_r == 0 & im1t_g == 0 & im1t_b == 0, 'dilate', 1));
    ind2 = find(bwmorph(im2t_r == 0 & im2t_g == 0 & im2t_b == 0, 'dilate', 1));
    T = sparse([ind1; ind2], [ones(numel(ind1), 1) .* 2; ones(numel(ind2), 1)], ones(numel(ind1) + numel(ind2), 1) * 9e9, N, 2);
    
    % Compute maximum flow
    [~, labels] = maxflow(A, T);
    labels = reshape(double(labels), [height width]);
    
    % Smooth labels (feathering)
    if strcmpi(method, 'feather')
        filter_size = 15;
        W = fspecial('gaussian', [filter_size filter_size], 4);
        labels(floor(filter_size ./ 2):end - ceil(filter_size ./ 2), ...
               floor(filter_size ./ 2):end - ceil(filter_size ./ 2)) = conv2(labels, W, 'valid');
    end
    
    % Blend final image (in image domain)
    if any(strcmpi(method, {'simple', 'feathering'}))
        trans_im = max(im1t, im2t);
        trans_im(min_r:max_r, min_c:max_c, 1) = uint8(round((1 - labels) .* im1t_r + labels .* im2t_r));
        trans_im(min_r:max_r, min_c:max_c, 2) = uint8(round((1 - labels) .* im1t_g + labels .* im2t_g));
        trans_im(min_r:max_r, min_c:max_c, 3) = uint8(round((1 - labels) .* im1t_b + labels .* im2t_b));
    else
    
        % Blend final image (in image gradient domain)
        trans_im = max(im1t, im2t);

        im1t_r_dy = [diff(im1t_r, [], 1); zeros(1, size(im1t_r, 2))]; im1t_r_dy(ind1) = 0;  
        im1t_g_dy = [diff(im1t_g, [], 1); zeros(1, size(im1t_g, 2))]; im1t_g_dy(ind1) = 0;
        im1t_b_dy = [diff(im1t_b, [], 1); zeros(1, size(im1t_b, 2))]; im1t_b_dy(ind1) = 0;
        im2t_r_dy = [diff(im2t_r, [], 1); zeros(1, size(im2t_r, 2))]; im2t_r_dy(ind2) = 0;   
        im2t_g_dy = [diff(im2t_g, [], 1); zeros(1, size(im2t_g, 2))]; im2t_g_dy(ind2) = 0;   
        im2t_b_dy = [diff(im2t_b, [], 1); zeros(1, size(im2t_b, 2))]; im2t_b_dy(ind2) = 0;

        im1t_r_dx = [zeros(size(im1t_r, 1), 1) diff(im1t_r, [], 2)]; im1t_r_dx(ind1) = 0;
        im1t_g_dx = [zeros(size(im1t_g, 1), 1) diff(im1t_g, [], 2)]; im1t_g_dx(ind1) = 0;
        im1t_b_dx = [zeros(size(im1t_b, 1), 1) diff(im1t_b, [], 2)]; im1t_b_dx(ind1) = 0;
        im2t_r_dx = [zeros(size(im2t_r, 1), 1) diff(im2t_r, [], 2)]; im2t_r_dx(ind2) = 0;
        im2t_g_dx = [zeros(size(im2t_g, 1), 1) diff(im2t_g, [], 2)]; im2t_g_dx(ind2) = 0;
        im2t_b_dx = [zeros(size(im2t_b, 1), 1) diff(im2t_b, [], 2)]; im2t_b_dx(ind2) = 0;

        combined_r_dy = (1 - labels) .* im1t_r_dy + labels .* im2t_r_dy;
        combined_g_dy = (1 - labels) .* im1t_g_dy + labels .* im2t_g_dy;
        combined_b_dy = (1 - labels) .* im1t_b_dy + labels .* im2t_b_dy;
        combined_r_dx = (1 - labels) .* im1t_r_dx + labels .* im2t_r_dx;
        combined_g_dx = (1 - labels) .* im1t_g_dx + labels .* im2t_g_dx;
        combined_b_dx = (1 - labels) .* im1t_b_dx + labels .* im2t_b_dx;

        combined_r_hat = poisson_solver_function(combined_r_dx, combined_r_dy, trans_im(min_r:max_r, min_c:max_c, 1));
        combined_g_hat = poisson_solver_function(combined_g_dx, combined_g_dy, trans_im(min_r:max_r, min_c:max_c, 2));
        combined_b_hat = poisson_solver_function(combined_b_dx, combined_b_dy, trans_im(min_r:max_r, min_c:max_c, 3));

        trans_im(min_r:max_r, min_c:max_c, 1) = combined_r_hat;
        trans_im(min_r:max_r, min_c:max_c, 2) = combined_g_hat;
        trans_im(min_r:max_r, min_c:max_c, 3) = combined_b_hat;
    end
    imshow(trans_im);
    