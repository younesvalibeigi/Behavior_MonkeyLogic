% reducing contrast
function [cir_dim, rad_dim] = reduce_contrast(cir, rad, ratio)
    
    if ndims(cir) == 2
        [height, width] = size(cir);
    elseif ndims(cir) == 3
        [height, width, z] = size(cir);
    end
    cir_dim = uint8(((double(cir)-127)/ratio)+127);
    rad_dim = uint8(((double(rad)-127)/ratio)+127);
end