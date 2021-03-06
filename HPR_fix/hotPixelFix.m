%% Used for hot pixel removal on all images ; use after decoding and before recolouring.

function hotPixelFix( distThresh, closeNThresh, wSize, dataPath, outputPath )

wBorder = (wSize-1)/2;
files = dir(dataPath);
dirFlags = [files.isdir];
images = files(~dirFlags);

for f = 1:length(images)
    image = fullfile(dataPath, images(f).name);
    fprintf('HPR : processing image %s\n', images(f).name);

    r = floor((f-1)/15);
    c = mod(f-1, 15);
    if(r < 10)
      if(c < 10)
          outname = sprintf('0%d0%d.png', r, c);
      else
          outname = sprintf('0%d%d.png', r, c);
      end
    else
      if(c < 10)
          outname = sprintf('%d0%d.png', r, c);
      else
          outname = sprintf('%d%d.png', r, c);
      end
    end
    
    outfile = fullfile(outputPath, outname);

    I = imread(image);
    [x,y,~] = size(I);

    Ilab = rgb2lab(double(I)./255); % use Lab instead of RGB
    for xi = 1:x
        for yi = 1:y
            
            pix(1) = double(Ilab(xi, yi, 1));
            pix(2) = double(Ilab(xi, yi, 2));
            pix(3) = double(Ilab(xi, yi, 3));

            W = zeros(wSize, wSize, 3); % window around the current pixel to store colour values
            closeNeighbourCount = 0;

            % For edges
            if(xi < wBorder+1 && yi < wBorder+1 )
                patch = Ilab(1:xi + wBorder , 1:yi+wBorder, :);
                W = padarray(patch,[(wBorder+1 - xi) (wBorder+1 - yi)], 'post','symmetric');
            elseif(xi < wBorder+1 && yi > y-wBorder )
                patch = Ilab(1:xi+( wBorder ), yi-wBorder:y, :);
                W = padarray(patch,[(wBorder+1 - xi) wBorder-(y-yi)], 'post','symmetric');
            elseif(xi < wBorder+1)
                patch = Ilab(1:xi+( wBorder ), yi-wBorder:yi+wBorder, :);
                W = padarray(patch,[(wBorder+1 - xi) 0], 'post','symmetric');
            elseif(xi > x-wBorder && yi < wBorder+1 )
                patch = Ilab((xi-wBorder):x, 1:yi+wBorder, :);
                W = padarray(patch,[wBorder-(x-xi) (wBorder+1 - yi)], 'post','symmetric');
            elseif(xi  > x-wBorder && yi > y-wBorder )
                patch = Ilab((xi-wBorder):x, yi-wBorder:y, :);
                W = padarray(patch,[wBorder-(x-xi) wBorder-(y-yi)], 'post','symmetric');
            elseif(xi  > x-wBorder)
                patch = Ilab((xi-wBorder):x, yi-wBorder:yi+wBorder, :);
                W = padarray(patch,[wBorder-(x-xi) 0], 'post','symmetric');
            elseif(yi  < wBorder+1)
                patch = Ilab((xi-wBorder):(xi+wBorder), 1:yi+wBorder, :);
                W = padarray(patch,[0 (wBorder+1 - yi)], 'post','symmetric');
            elseif(yi  > y-wBorder)
                patch = Ilab((xi-wBorder):(xi+wBorder), yi-wBorder:y, :);
                W = padarray(patch,[0 wBorder-(y-yi)], 'post','symmetric');
            else
                W = Ilab((xi-wBorder):xi+wBorder, yi-wBorder:yi+wBorder, :); 
            end
            for i = 1:wSize
                for j = 1:wSize
                    dist = sqrt(power(W(i, j, 1) - pix(1), 2) + power(W(i, j ,2) - pix(2), 2) + power(W(i, j, 3) - pix(3), 2));

                    if(dist < distThresh)
                        closeNeighbourCount = closeNeighbourCount + 1;
                    end
                end
            end

            white = [100 0 0 ];
            if(closeNeighbourCount < closeNThresh && (sqrt(power(white(1) - pix(1), 2) + power(white(2) - pix(2), 2) + power(white(3) - pix(3), 2)))>30)
                % fill in the outlier pixel with the median value from its 3x3 window
                W1 = reshape(W(wBorder:wBorder+2,wBorder:wBorder+2,:), [9, 3] ); % get the 3x3 neighbourhood around the pixel
                W1(5,:) = []; % remove the noisy pixel from this 
                med = 255*lab2rgb(median(W1)); % get the median of the remaining pixels in the window
                
                % change the colour of the centre pixel
                I(xi, yi, 1) = med(1);
                I(xi, yi, 2) = med(2);
                I(xi, yi, 3) = med(3);
            end
        end
    end

    imwrite(I, outfile);
end

end % function mg_noiseDetectFun

