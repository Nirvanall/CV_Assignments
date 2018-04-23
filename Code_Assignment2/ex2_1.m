%% Exercise 2.1 Computing SIFT descriptors
I1 = imreadbw('img1.jpg');
I2 = imreadbw('img2.jpg');
[frames1, descr1] = sift(I1, 'Threshold', 0.05);
[frames2, descr2] = sift(I2, 'Threshold', 0.05);

figure
for i=1:9
    subplot(3,3,i);
    plotsiftdescriptor(descr1(:,i));
    axis off
end

%% Exercise 2.2. Matching SIFT feature points
[matches] = siftmatch_nn(descr1, descr2, 0.39);
figure
plotmatches(I1, I2, frames1(1:2, :), frames2(1:2, :),matches);