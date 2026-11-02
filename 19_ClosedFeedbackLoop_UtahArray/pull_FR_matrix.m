function [FR, rows, cols] = pull_FR_matrix(ip, port)
    % Reuses a persistent TCP client across calls. Reconnects only if needed.
    %FR = zeros(32,0); rows = uint32(0); cols = uint32(0);
    t = [];
    if isempty(t) || ~isvalid(t)
        t = tcpclient(ip, port, "Timeout", 5);
        configureTerminator(t, "LF");
        fprintf("Connected to %s:%d\n", ip, port);
    end

    % 1) ask the server
    writeline(t, "GET");

    % 2) read header: 8 bytes => [rows, cols] as uint32
    need_hdr = 8;
    hdr_bytes = read(t, need_hdr, 'uint8');
    if numel(hdr_bytes) ~= need_hdr
        error("Timeout waiting for header (needed %d bytes, got %d).", need_hdr, numel(hdr_bytes));
    end
    dims = typecast(uint8(hdr_bytes), 'uint32');
    rows = double(dims(1));
    cols = double(dims(2));

    % 3) read payload: rows*cols * 8 bytes (single precision)
    need_payload = rows * cols * 8;  % bytes
    payload = read(t, need_payload, 'uint8');
    if numel(payload) ~= need_payload
        error("Timeout waiting for payload (needed %d bytes, got %d).", need_payload, numel(payload));
    end

    % 4) reconstruct matrix
    FR = reshape(typecast(uint8(payload), 'double'), rows, cols);

    % 5) do something with it (quick peek)
    fprintf("[%s] Received %dx%d matrix. min=%.3f  max=%.3f  mean=%.3f\n", ...
        datestr(now,'HH:MM:SS'), rows, cols, min(FR(:)), max(FR(:)), mean(FR(:)));

    % pause before next request
    %pause(2);

end
