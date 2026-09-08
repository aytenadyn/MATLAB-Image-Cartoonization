
function cartoon_image_gui()
    % GUI part
    f = figure('Position', [100, 100, 800, 600]);

   
    uicontrol('Style', 'pushbutton', 'String', 'Load Image', ...
              'Position', [50, 550, 200, 30], 'Callback', @load_image);

    
    uicontrol('Style', 'text', 'Position', [50, 500, 300, 20], ...
              'String', 'Cartoon Level (0 to 10)');
    slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 10, 'Value', 6, ...
                       'Position', [50, 470, 300, 20], 'Callback', @update_image);

    
    image_axes = axes('Position', [0.1, 0.1, 0.8, 0.8],'Visible','off');

   
    img = [];
    cartoon_level = 6;

    %
    function load_image(~, ~)
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select an Image');
        if file ~= 0
            img = imread(fullfile(path, file));
            setappdata(f, 'image', img);
            update_image();
        end
    end

    
    function update_image(~, ~)
        if isempty(img)
            return;
        end
        %Color Quantization Part     
        cartoon_level = round(get(slider, 'Value'));
        
        B = 256;
        L = 14- cartoon_level;
        if L < 0
    error('Invalid cartoon level: L must be positive.');
end
        q = B / L;

        Q = zeros(256, 1);
        for i = 0:255
            Q(i+1, 1) = floor(i / q) * q + q / 2;
        end

        y = zeros(size(img));
        for ch = 1:size(img, 3)
            for i = 1:size(img, 1)
                for j = 1:size(img, 2)
                    y(i, j, ch) = Q(img(i, j, ch) + 1);
                end
            end
        end

        % Apply manual bilateral filtering
        y_filtered = zeros(size(y));
        [rows, cols, ~] = size(y);
        window_size =10;
        half_window = floor(window_size / 2);
        sigma_spatial = 10;
        sigma_intensity = 20;

        for ch = 1:size(y, 3)
            channel = y(:, :, ch);
            filtered_channel = zeros(rows, cols);

            for i = 1:rows
                for j = 1:cols
                    r_min = max(1, i - half_window);
                    r_max = min(rows, i + half_window);
                    c_min = max(1, j - half_window);
                    c_max = min(cols, j + half_window);

                    local_window = channel(r_min:r_max, c_min:c_max);

                    
                    [x, y_coords] = meshgrid(c_min:c_max, r_min:r_max);
                    spatial_weights = exp(-((x - j).^2 + (y_coords - i).^2) / (2 * sigma_spatial^2));

                   
                    intensity_weights = exp(-(local_window - channel(i, j)).^2 / (2 * sigma_intensity^2));

                    
                    bilateral_weights = spatial_weights .* intensity_weights;

                    
                    bilateral_weights = bilateral_weights / sum(bilateral_weights(:));

                    
                    filtered_channel(i, j) = sum(bilateral_weights(:) .* local_window(:));
                end
            end

            y_filtered(:, :, ch) = filtered_channel;
        end
        %Canny Edge Detection Part
        y_gray = rgb2gray(uint8(y_filtered));
        sigma = 3;
        G = fspecial('gaussian', [30 30], sigma);
        I_smoothed = imfilter(y_gray, G, 'same');
        [Gx, Gy] = imgradientxy(I_smoothed);
        [gradient_magnitude, gradient_direction] = imgradient(Gx, Gy);

        [m, n] = size(gradient_magnitude);
        nms = zeros(m, n);
        for i = 2:m-1
            for j = 2:n-1
                angle = gradient_direction(i, j);
                if ((angle >= -22.5 && angle <= 22.5) || (angle >= 157.5 || angle <= -157.5))
                    neighbors = [gradient_magnitude(i, j-1), gradient_magnitude(i, j+1)];
                elseif ((angle > 22.5 && angle <= 67.5) || (angle < -112.5 && angle >= -157.5))
                    neighbors = [gradient_magnitude(i-1, j+1), gradient_magnitude(i+1, j-1)];
                elseif ((angle > 67.5 && angle <= 112.5) || (angle < -67.5 && angle >= -112.5))
                    neighbors = [gradient_magnitude(i-1, j), gradient_magnitude(i+1, j)];
                else
                    neighbors = [gradient_magnitude(i-1, j-1), gradient_magnitude(i+1, j+1)];
                end

                if gradient_magnitude(i, j) >= max(neighbors)
                    nms(i, j) = gradient_magnitude(i, j);
                else
                    nms(i, j) = 0;
                end
            end
        end
     
        high_threshold = max(nms(:)) * 0.2; 
        low_threshold = high_threshold * 0.1;
        strong_edges = (nms >= high_threshold);
        weak_edges = (nms < high_threshold) & (nms >= low_threshold);

        edges = strong_edges;
        for i = 2:m-1
            for j = 2:n-1
                if weak_edges(i, j)
                    if any(any(strong_edges(i-1:i+1, j-1:j+1)))
                        edges(i, j) = 1;
                    end
                end
            end
        end

        edges_colored = uint8(edges) * 0;
        colored_edges = cat(3, edges_colored, edges_colored, edges_colored);
        final_image = uint8(y_filtered) + colored_edges;
        final_image(final_image > 255) = 255;

        axes(image_axes);
        imshow(final_image);
        title(['Quantized, Filtered, and Edge Detected Image (L= ', num2str(cartoon_level), ')']);
    end
end
