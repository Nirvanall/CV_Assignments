%% Rotation and scale invariance
I = imreadbw('img1.jpg');
figure
imshow(I);
[r, c] = harris(I);
hold on
scatter(c, r, 12);
hold off

[rr, cr] = harris(I');
figure
imshow(I);
hold on
scatter(rr, cr, 12);
hold off


Im = imresize(I, 0.5);
figure
imshow(Im);
hold on
[rs, cs] = harris(Im);
scatter(cs, rs, 12);
hold off
% Find less corners


