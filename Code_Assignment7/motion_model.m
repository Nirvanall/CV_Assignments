function s_t = motion_model(s_t1, VIDEO_WIDTH, VIDEO_HEIGHT)
%MOTION_MODEL Implementation of sampling from a simple motion model
%
%   s_t = motion_model(s_t1, VIDEO_WIDTH, VIDEO_HEIGHT)
%
% Given a past state vector s_t1, this function samples a new state vector 
% s_t by sampling from the motion model.


    % TODO: Define your motion prediction model, and apply it to sample a 
    % new state s_t given the previous state s_t1. Remember to handle the 
    % boundary conditions where the state estimate reaches the edges of the 
    % video sequence. Use a Gaussian motion model with sigma = 15.
    s_t = s_t1;
    sigma = 15;
    N = 100; % number of particles
    s_t(:,1) = sqrt(sigma)*randn(N, 1) + s_t1(:,1);
    s_t(:,2) = sqrt(sigma)*randn(N, 1) + s_t1(:,2);
    % ...
    
    % Ensure that the particles never go out-of-bounds
    s_t(:,1) = max(1, min(VIDEO_WIDTH  - ceil(.5 .* s_t(:,5) .* s_t(:,6)), s_t(:,1)));
    s_t(:,2) = max(1, min(VIDEO_HEIGHT - ceil(.5 .* s_t(:,6)),             s_t(:,2)));    
