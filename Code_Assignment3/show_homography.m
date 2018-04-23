function trans_im = show_homography(im1, im2, H)
%SHOW_HOMOGRAPHY Shows a homography between two images
%


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
    
    % Show transformed image
    trans_im = im2t;
    mask = all(trans_im == 0, 3);
    trans_im_r = trans_im(:,:,1);
    trans_im_g = trans_im(:,:,2);
    trans_im_b = trans_im(:,:,3);
    im1t_r = im1t(:,:,1);
    im1t_g = im1t(:,:,2);
    im1t_b = im1t(:,:,3);
    trans_im_r(mask) = im1t_r(mask);
    trans_im_g(mask) = im1t_g(mask);
    trans_im_b(mask) = im1t_b(mask);
    trans_im(:,:,1) = trans_im_r;
    trans_im(:,:,2) = trans_im_g;
    trans_im(:,:,3) = trans_im_b;
%     trans_im = uint8(round(bsxfun(@rdivide, double(im1t) + double(im2t), double(~all(im1t == 0, 3)) + double(~all(im2t == 0, 3)))));
%     trans_im = max(im1t, im2t);
    imshow(trans_im);
end
