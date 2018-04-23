function [boxes, response] = sliding_window_detector(im, W, block_size, hog_size)

    % Extract weights and bias
    bias = W.data.E_bias(2);
    W = W.data.E(:,2);

    % Perform multi-scale detection
    scales = logspace(log10(.2), log10(1), 10);
    responses = nan(size(im, 1), size(im, 2), length(scales));
    for i=1:length(scales)

        % Loop over strides
        stride = 1:2:8;                   % dense classification
        scaled_im = imresize(im, scales(i), 'bicubic');            
        for sx=1:length(stride)
            for sy=1:length(stride)

                % Perform HOG extraction
                all_feat = hog(scaled_im(stride(sy):end, stride(sx):end,:), block_size);

                % Evaluate classifier at all locations
                if sx == 1 && sy == 1
                    tmp_response = zeros(length(stride) * (size(all_feat, 1) - hog_size(1)), ...
                                         length(stride) * (size(all_feat, 2) - hog_size(2)));
                end
                for y=1:size(all_feat, 1) - hog_size(1)                 % can we do this in one go?!
                    for x=1:size(all_feat, 2) - hog_size(2)
                        feat = all_feat(y:y + hog_size(1) - 1, ...
                                        x:x + hog_size(2) - 1,:);
                        tmp_response((y - 1) * length(stride) + sy, ...
                                     (x - 1) * length(stride) + sx) = 1 ./ (1 + exp(-W' * feat(:) + bias));
                    end
                end
            end
        end

        % Interpolate classifier responses
        if all(size(tmp_response) > 0)
            border_y = (size(scaled_im, 1) - (size(all_feat, 1) * block_size)) / 2;
            border_x = (size(scaled_im, 2) - (size(all_feat, 2) * block_size)) / 2;
            [xq, yq] = meshgrid(1:size(responses, 2), 1:size(responses, 1));
            start_x = border_x + (1 / scales(i)) * block_size * floor(size(feat, 2) / 2);
            start_y = border_y + (1 / scales(i)) * block_size * floor(size(feat, 1) / 2);
            step = (1 / (scales(i) * length(stride))) * block_size;
            responses(:,:,i) = interp2(start_x:step:start_x + step * (size(tmp_response, 2) - 1), ...
                                       start_y:step:start_y + step * (size(tmp_response, 1) - 1), tmp_response, xq, yq);
        end
    end
    
    % Find maxima in responses
    response = max(responses, [], 3);

    % Find detections via non-maxima suppression
    boxes = zeros(0, 5);
    for i=1:length(scales)
        [r, c] = nonmaxsuppts(responses(:,:,i), 3, .6);
        v = responses(r, c, i); 
        for k=1:length(r)
            boxes(end + 1,:) = [r(k) - (1 ./ scales(i)) * block_size * floor(hog_size(1) ./ 2) ...
                                c(k) - (1 ./ scales(i)) * block_size * floor(hog_size(2) ./ 2) ...
                                r(k) + (1 ./ scales(i)) * block_size *  ceil(hog_size(1) ./ 2) ...
                                c(k) + (1 ./ scales(i)) * block_size *  ceil(hog_size(2) ./ 2) ...
                                v(k)];
        end
    end
    boxes = nms(boxes, .4);

