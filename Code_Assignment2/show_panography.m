function show_panography(im1, im2, trans, type)

    assert(all(size(im1) == size(im2)));

    
    % Construct a combined image
    base_y = max(1, -round(trans(2)));
    base_x = max(1, -round(trans(1)));
    combined_im = zeros([size(im1, 1) + ceil(abs(trans(2))) + 1 ...
                         size(im1, 2) + ceil(abs(trans(1))) + 1 3], 'double');
    combined_im(base_y:base_y + size(im1, 1) - 1, ...
                base_x:base_x + size(im1, 2) - 1,:) = im1;
    if strcmpi(type, 'hard')
        combined_im(1 + base_y + round(trans(2)):base_y + round(trans(2)) + size(im2, 1), ...
                    1 + base_x + round(trans(1)):base_x + round(trans(1)) + size(im2, 2),:) = im2;
    else
        combined_im(1 + base_y + round(trans(2)):base_y + round(trans(2)) + size(im2, 1), ...
                    1 + base_x + round(trans(1)):base_x + round(trans(1)) + size(im2, 2),:) = ...
        combined_im(1 + base_y + round(trans(2)):base_y + round(trans(2)) + size(im2, 1), ...
                    1 + base_x + round(trans(1)):base_x + round(trans(1)) + size(im2, 2),:) + im2;
        count = zeros([size(im1, 1) + ceil(abs(trans(2))) + 1 ...
                       size(im1, 2) + ceil(abs(trans(1))) + 1]);
        count(base_y:base_y + size(im1, 1) - 1, ...
              base_x:base_x + size(im1, 2) - 1) = 1;
        count(1 + base_y + round(trans(2)):base_y + round(trans(2)) + size(im2, 1), ...
              1 + base_x + round(trans(1)):base_x + round(trans(1)) + size(im2, 2)) = ...
        count(1 + base_y + round(trans(2)):base_y + round(trans(2)) + size(im2, 1), ...
              1 + base_x + round(trans(1)):base_x + round(trans(1)) + size(im2, 2)) + 1;
        combined_im = bsxfun(@rdivide, combined_im, count);
        combined_im(isinf(combined_im)) = 1;
    end
    
    % Show combined image
    figure, imshow(combined_im);
   