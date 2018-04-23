%% Exercise 5.1 Iterated conditional modes
im = imread('image.png');
im = rgb2gray(im);
[h, w] = size(im);
[val, ~, im] = unique(im);
im = reshape(im, [h w]);
im(im ==2) = -1;
true_im = im;

figure
imagesc(true_im);

mask = (rand(size(im)) > .9);
im(mask) = -im(mask);
noisy_im = im;

figure
imagesc(noisy_im);

eta = .1;
alpha = -.05;
beta = .2;

for i = 1:25
for stride_x = 2:w-1
    for stride_y = 2:h-1
        i1 = eta*noisy_im(stride_y, stride_x) + alpha + ...
            beta* (noisy_im(stride_y - 1, stride_x)+...
            noisy_im(stride_y + 1, stride_x) + ...
            noisy_im(stride_y, stride_x - 1) + ...
            noisy_im(stride_y, stride_x + 1));
        i0 = -eta*noisy_im(stride_y, stride_x) - alpha - ...
            beta* (noisy_im(stride_y - 1, stride_x)+...
            noisy_im(stride_y + 1, stride_x) + ...
            noisy_im(stride_y, stride_x - 1) + ...
            noisy_im(stride_y, stride_x + 1));
        if (i1 > i0)
            im(stride_y, stride_x) = 1;
        else
            im(stride_y, stride_x) = -1;
        end
        
    end
end

noisy_im = im;
if (i == 1)
  err1 = 0.5*sum(sum(abs(true_im - noisy_im)))/(h*w);
end
end

figure
imagesc(noisy_im);

err = 0.5*sum(sum(abs(true_im - noisy_im)))/(h*w);




