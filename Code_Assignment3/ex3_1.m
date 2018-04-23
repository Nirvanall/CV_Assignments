%% Exercise 3.1 Fitting a homography
I1 = imread('images/im89.jpg');
I2 = imread('images/im90.jpg');

[frames1, descr1] = sift(rgb2gray(I1), 'Threshold', 0.05);
[frames2, descr2] = sift(rgb2gray(I2), 'Threshold', 0.05);

p1_x = frames1(1,:);
p1_y = frames1(2,:);
p2_x = frames2(1,:);
p2_y = frames2(2,:);
matches = siftmatch(descr1, descr2, 2.0);

H = fit_homography(p1_x, p1_y, p2_x, p2_y, matches);
figure
show_homography(I2, I1, H);
figure
show_homography(I1, I2, inv(H));




