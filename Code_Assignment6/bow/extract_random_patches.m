function patches = extract_random_patches(image_list, patches_per_image, patch_size)


    % Fill patches matrix
    patches = zeros(patch_size .^ 2, length(image_list) * patches_per_image);
    index = 0;
    for i=1:length(image_list)
        
        % Load image and convert to grayscale between 0 and 1
        im = imread(image_list{i});
        if ~ismatrix(im)
            im = rgb2gray(im);
        end
        im = double(im) ./ 255;
        
        % Extract a number of patches
        for j=1:patches_per_image
            
            % Get an random patch
            y = 1 + randi(size(im, 1) - patch_size - 1);
            x = 1 + randi(size(im, 2) - patch_size - 1);
            patch = im(y:y + patch_size - 1, ...
                       x:x + patch_size - 1);
                   
            % Store the random patch
            index = index + 1;
            patches(:,index) = patch(:);
        end
    end
    