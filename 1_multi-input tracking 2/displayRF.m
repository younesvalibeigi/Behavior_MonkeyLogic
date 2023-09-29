function displayRF(rf_position, rf_radius, file_addr_name)
    str0 = '-------------------------';
    str1 = 'RF coordinates: ';
    str2 = 'RF Radius: ';
    str3 = 'RF distance';
    disp(str0); 
    disp(str1); 
    disp(rf_position); 
    disp(str2); 
    disp(rf_radius); 
    disp(str3); 
    dist = (rf_position(1)^2 + rf_position(2)^2)^0.5;
    disp(dist)
    mat = [rf_position(1), rf_position(2), rf_radius, dist];
    writematrix(mat, file_addr_name, 'WriteMode', 'append')

end