function send_FR_end_task(ip, port)
% send_FR_end_task  Tell the RHX FR server to stop RHX and exit its loop.
% Never throws: a failure only prints a warning, so saving can continue.
try
    t = tcpclient(ip, port, "Timeout", 5);
    configureTerminator(t, "LF");
    writeline(t, "End_Task");
    pause(0.1);
    clear t
    fprintf('[FR server] End_Task sent to %s:%d\n', ip, port);
catch ME
    warning('Could not send End_Task to the FR server (%s).', ME.message);
end
end
