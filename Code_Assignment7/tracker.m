
    % Read the video sequence into videoSeq as a cell
    disp('Loading image files from the video sequence...');
    imgPath = './sequence/'; 
    dCell = dir([imgPath '*.png']);
    videoSeq = cell(length(dCell), 1);
    for d = 1:length(dCell)
        videoSeq{d} = imread([imgPath dCell(d).name]);
    end

    % Create a figure we will use to display the video sequence
    clf; figure(1); set(gca, 'Position', [0 0 1 1]);
    imshow(videoSeq{1});

    % Determine the size of the video frames
    VIDEO_WIDTH  = size(videoSeq{1},2);  
    VIDEO_HEIGHT = size(videoSeq{1},1);

    % Set up a GUI to manually annotate the object of interest
    display('Initialize the bounding box by selecting the object...');
    [patch, bB] = imcrop(); bB = round(bB);

    % Fill the initial state vector with our manual initialization
    s_init = [bB(1) bB(2) 0 0 bB(3)/bB(4) bB(4)];

    % Draw a bouding box on the image showing the initial state estimate
    draw_box(s_init);

    % TODO: Initialize the color model of your object of interest
     color_model = color_histogram(patch);
    
    % TODO: Initialize the particle set here. Store the particles in an Nx6
    % matrix s_t, with an associated Nx1 weight vector w_t.
    N = 100;                              % the number of particles to use
    w_t = ones(N,1)/N;
    s_t = repmat(s_init,N,1);
    % ...
    
    % Loop through the video and estimate the state at each time step, t
    T = length(videoSeq);
    for t=1:1

        % Load the current image and display it in the figure
        I = videoSeq{t}; figure(1); cla; imshow(I); hold on;
        
        % TODO: Randomly sample particles according to weights
        [s_t1, idx] = datasample(w_t,N, 'Weights', w_t);
        for j = 1:N
            s_t2(j, :) = s_t(idx(j), :);
            w_t1(j, :) = w_t(idx(j), :);
        end
        s_t = s_t2;
        w_t = w_t1./sum(w_t1);

        % TODO: Move the particles according to the motion model
         s_t = motion_model(s_t,VIDEO_WIDTH, VIDEO_HEIGHT );
     
        % TODO: Compute the appearance likelihood for each particle
         L = zeros(N, 1);
         for i = 1:N
             L(i) = appearance_model(s_t(i,:), I, color_model, VIDEO_WIDTH, VIDEO_HEIGHT);
         end
        
        % TODO: Update particle weights
         w_t = w_t.*L;
         w_t = w_t./sum(w_t);
        
        % TODO: Estimate the object location based on the particles
         estimate_t = w_t'*s_t;
        
        % Draw particle filter estimate and particle locations
        draw_box(estimate_t, [0 1 0]); hold on
        scatter(s_t(:,1) + .5 .* s_t(:,5) .* s_t(:,6), s_t(:,2) + .5 .* s_t(:,6));
        hold off
        drawnow;
    end
