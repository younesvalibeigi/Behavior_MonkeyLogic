function g = rhx_global_chan(port, ch)
% Port 'A'/'B'/'C' + channel 0..31  ->  global 0-based index 0..95
%   A-022 -> 22,  B-022 -> 54,  C-022 -> 86.   ch < 0 -> -1 (no channel)
if any(ch < 0)
    g = -1;
    return
end
p = upper(char(port));
if numel(p) ~= 1 || ~any(p == 'ABC')
    error('rhx_global_chan: port must be ''A'', ''B'' or ''C'' (got ''%s'').', p);
end
if any(ch > 31) || any(ch ~= round(ch))
    error('rhx_global_chan: channel must be an integer 0..31.');
end
g = 32*(p - 'A') + ch;      % A->+0, B->+32, C->+64
end