%% Scale-invariant feature transform
I1 = imreadbw('img1.jpg');
I1 = I1 - min(I1(:));
I1 = I1 / max(I1(:));
figure
imshow(I1);

I2 = imreadbw('img2.jpg');
I2 = I2 - min(I2(:));
I2 = I2 / max(I2(:));
figure
imshow(I2);

[frames1, descr1, gss1, dogss1] = sift(I1, 'Threshold', 0.05);
[frames2, descr2, gss2, dogss2] = sift(I2, 'Threshold', 0.05);

figure
plotss(dogss1); colormap gray;
figure
plotss(dogss2); colormap gray;

figure
subplot(1,2,1)
imagesc(I1); colormap gray; axis off;
hold on
h1 = plotsiftframe(frames1); set(h1, 'LineWidth', 2, 'Color', 'g');
h2 = plotsiftframe(frames1); set(h2, 'LineWidth', 1, 'Color', 'k');
hold off

subplot(1,2,2)
imagesc(I2); colormap gray; axis off;
hold on
h3 = plotsiftframe(frames2); set(h3, 'LineWidth', 2, 'Color', 'g');
h4 = plotsiftframe(frames2); set(h4, 'LineWidth', 1, 'Color', 'k');
hold off

Is = imresize(I2, 0.5);
[frames3, descr3, gss3, dogss3] = sift(Is, 'Threshold', 0.05);
figure
plotss(dogss3); colormap gray;
figure
imagesc(Is); colormap gray; axis off;
hold on
h3 = plotsiftframe(frames3); set(h3, 'LineWidth', 2, 'Color', 'g');
h4 = plotsiftframe(frames3); set(h4, 'LineWidth', 1, 'Color', 'k');
hold off

% Some feature points are the same

