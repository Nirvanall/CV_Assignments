


    counter = 0;
    patch_size = [160 96];
    files = dir('images/neg/*.*');
    for i=1:length(files)
        if ~rem(i, 20);
            fprintf('.');
        end
        if ~files(i).isdir
            im = imread(['images/neg/' files(i).name]);
            for j=1:10
                y = randi(size(im, 1) - patch_size(1));
                x = randi(size(im, 2) - patch_size(2));
                counter = counter + 1;
                str = ['00000' num2str(counter)]; str = str(end - 4:end);
                imwrite(im(y:y+patch_size(1) - 1, ...
                           x:x+patch_size(2) - 1,:), ['images/negative/neg_' str '.png']);
            end
        end
    end
    disp(' ');