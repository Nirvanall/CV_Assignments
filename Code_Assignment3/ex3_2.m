%% Exercise 3.2 Image stitching
I1 = imread('images/im89.jpg');
I2 = imread('images/im90.jpg');

H = find_homography(I1, I2);
figure
show_homography(I1, I2, inv(H));
figure
show_nice_homography(I1, I2, inv(H), 'simple');
figure
show_nice_homography(I1, I2, inv(H), 'feathering');
figure
show_nice_homography(I1, I2, inv(H), 'gradient');