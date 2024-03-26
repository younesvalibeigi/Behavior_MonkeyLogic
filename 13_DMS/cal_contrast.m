% reducing contrast
function contrastLevel = cal_contrast(image)
    % Convert the image to double for accurate calculations
    image = im2double(image);
    
    % Calculate the maximum and minimum intensity values
    Imax = max(image(:));
    Imin = min(image(:));
    
    % Calculate the contrast level
    contrastLevel = (Imax - Imin) / (Imax + Imin);
end