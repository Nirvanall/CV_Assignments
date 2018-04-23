function [matches] = siftmatch_nn(descr1, descr2, threshold)

[~, n] = size(descr1); % number of descriptors in image1
[~, m] = size(descr2); % number of descriptors in image2

ED = zeros(n,m); % Euclidean distance between descr1 and descr2
matches = zeros(2, n);
minED = zeros(n,1);
index = 1;
for i = 1:n
    for j = 1:m
        ED(i,j) = norm(descr1(:,i)-descr2(:,j));
    end
    
    minED(i,1) = min(ED(i,:));
    if (minED(i,1) < threshold)          % the nearest neighbor in descr2 
        p = find(ED(i,:) == minED(i,1)); % for each descriptor in descr1
        matches(:, index) = [i; p];
        index = index + 1;
    end   
end

for k = n:-1:1
    if( matches(1,k) == 0)
        matches(:,k)=[];
    end
end

end