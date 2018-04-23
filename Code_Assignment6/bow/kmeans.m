function [clusters, assign] = kmeans(X, K)
%KMEANS Memory-efficient implementation of k-means clustering
%
%   [clusters, assign] = kmeans(X, K)
%
% Memory-efficient implementation of k-means clustering.


    % Initialize some variables
    tol = 1e-5;
    max_iter = 100;
    batch_size = 2 ^ 13;
    N = size(X, 2);
    assign = zeros(1, N);
    
    % Initialize clusters from data points
    perm = randperm(N);
    clusters = X(:,perm(1:K));
    
    % Perform precomputation
    X2 = sum(X .^ 2, 1);
    
    % Perform k-means iterations
    iter = 0; change = Inf;
    while iter < max_iter && change / N > tol
        
        % Perform pre-computation
        old_assign = assign;
        C2 = sum(clusters .^ 2, 1);
        
        % Loop over all batches
        for batch=1:batch_size:N
            
            % Compute pairwise distances
            ind = batch:min(N, batch + batch_size - 1);
            DD = bsxfun(@plus, C2', bsxfun(@plus, X2(ind), -2 .* (clusters' * X(:,ind))));
            
            % Compute assignments
            [~, assign(ind)] = min(DD, [], 1);
        end
        
        % Compute new cluster centers
        for k=1:K
            clusters(:,k) = mean(X(:,assign == k), 2);
        end
        
        % Print out progress
        iter = iter + 1;
        change = sum(assign ~= old_assign);
%         disp(['   * iteration ' num2str(iter) ': ' num2str(change ./ N .* 100) '% of the assignments changed']);
    end
    
    % Remove empty clusters
    [~, c] = find(isnan(clusters));
    clusters(:,unique(c)) = [];    
    