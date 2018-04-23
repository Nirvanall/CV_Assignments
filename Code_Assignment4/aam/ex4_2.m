%% Exercise 4.2 Training an active appearance model
base_folder = 'ARF';
show_annotations(base_folder);

no_shape_pcs = 10;
no_texture_pcs = 30;
[shape_model, texture_model] = learn_model(base_folder, no_shape_pcs, 1, no_texture_pcs);
shape_model.transf_mult = 'ARF';

save 'my_model.mat'
%%
load 'my_model.mat'
figure
show_model(shape_model, texture_model);

%% 4.3 Fitting an active appearance model
[images, points, israw] = get_file_lists(base_folder);
im = imread([base_folder '/images/' images(1).name]);
imshow(im);
[p, lambda, err, ind, diverged, precomp] = fit_model([], [], im,...
    shape_model, texture_model, 'color');
figure
show_result_fit([], [], im, p, lambda, 1, shape_model, texture_model);

%%
im = imread([base_folder '/images/' images(2).name]);
[p, lambda] = fit_model([], [], im, shape_model, ...
    texture_model, 'color', precomp);
figure
show_result_fit([], [], im, p, lambda, 1, shape_model, texture_model);

%% 4.4 Using the AAM fit parameters as features
p = cell(length(images), 1);
lambda = cell(length(images), 1);
diverged = repmat(true, [length(images) 1]);
for i = 1: length(images)
    disp(['Image' num2str(i) 'of' num2str(length(images)) '...']);
    im = imread([base_folder '/images/' images(i).name]);
    [p{i}, lambda{i}, err, ind, diverged(i)] = fit_model([], [], ...
        im, shape_model, texture_model, 'color', precomp);
end

%%
% Load labels, and remove diverged instances
load 'arf_labels.mat'
p(diverged) = [];
lambda(diverged) = [];
% Convert AAM fit parameters to a labeled dataset
p = cell2mat(p);
lambda = cell2mat(lambda);
X = prdataset([p(:,5:end) lambda(:,2:end)], emotion_labels);
save 'my_X.mat'
%%
load 'my_X.mat'
error = prcrossval(X, knnc([], 1), 10);
error_ldc = prcrossval(X, ldc([]), 10);
%error_

