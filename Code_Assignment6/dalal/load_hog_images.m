function [A, hog_size] = load_hog_images(pos_folder, pos_files, neg_folder, neg_files, block_size)


    % Load all positive examples
    for i=1:length(pos_files)
        im = im2double(imread([pos_folder pos_files(i).name]));
        im = im(1 + block_size:end - block_size, ...
                1 + block_size:end - block_size,:);
        feat = hog(im, block_size);
        if i == 1                                       % allocate memory
            A = zeros(numel(feat), length(pos_files) + ...
                                    length(neg_files));
            hog_size = size(feat);
        end
        A(:,i) = feat(:);
    end

    % Load all negative examples
    for i=1:length(neg_files)
        im = im2double(imread([neg_folder neg_files(i).name]));
        im = im(1 + block_size:end - block_size, ...
                1 + block_size:end - block_size,:);
        feat = hog(im, block_size);
        A(:,length(pos_files) + i) = feat(:);
    end
    
    % Convert to PRTools data set
    A = prdataset(A', [ones(length(pos_files), 1); ...
                    zeros(length(neg_files), 1)]);

 