%% Harris corner detector
% Step 1
I = imreadbw('img1.jpg');
f = [-2, -1, 0, 1, 2]; % filter
Ax2 = imfilter(I, f).^2; % result image gradients
Axy = imfilter(I, f).* imfilter(I,f');
Ayy = imfilter(I, f').^2;
figure
imshow(Ax2);
figure
imshow(Axy);
figure
imshow(Ayy);
% Step 2
fg = fspecial('gaussian', 15, 2); % Gaussian filter with sigma = 2
% Step 3
WIx2 = conv2(Ax2, fg, 'same');
figure
imshow(WIx2);
% Step 4

% Step 5
WIy2 = conv2(Ayy, fg, 'same');
WIxIy = conv2(Axy, fg, 'same');
% Step 6
lambda1 = (WIx2+WIy2)/2 + (WIxIy.^2+((WIx2-WIy2)/2).^2).^0.5;
lambda2 = (WIx2+WIy2)/2 - (WIxIy.^2+((WIx2-WIy2)/2).^2).^0.5;
figure
imagesc(lambda1);
figure
imagesc(lambda2);
% Step 7
harris_im = lambda1.*lambda2 - 0.06*(lambda1+lambda2).^2;
figure
imagesc(harris_im);
hold on
% Step 8
[r, c] = nonmaxsuppts(harris_im, 2, 0.1);
plot(c, r, 'ro','MarkerSize', 3);




