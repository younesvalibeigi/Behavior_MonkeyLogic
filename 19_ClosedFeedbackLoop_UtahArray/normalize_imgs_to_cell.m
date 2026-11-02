% ------------- helpers -------------
function IM = normalize_imgs_to_cell(IM)
    % Accepts:
    %   * cell array of HxWx3 uint8 images, OR
    %   * 4-D uint8 array (H x W x 3 x N)
    if iscell(IM)
        % verify format
        assert(all(cellfun(@(x) isnumeric(x)&&ndims(x)==3&&size(x,3)==3, IM)), ...
               'IMGS cell must contain HxWx3 numeric RGB images');
        IM = IM(:)';
    else
        % assume 4-D array
        assert(ndims(IM)==4 && size(IM,3)==3, ...
               'IMGS must be cell RGB or 4-D uint8 (H x W x 3 x N)');
        N = size(IM,4);
        tmp = cell(1,N);
        for i = 1:N
            tmp{i} = IM(:,:,:,i);
        end
        IM = tmp;
    end
end


