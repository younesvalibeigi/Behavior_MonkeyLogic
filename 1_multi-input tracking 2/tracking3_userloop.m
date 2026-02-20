% ============================
% NEW FILE: tracking3_userloop.m
% ============================
function [C,timingfile,userdefined_trialholder] = tracking3_userloop(MLConfig,TrialRecord)
pxperdeg = 36.039;
fix = [0 0];
img_size = [1 1]*pxperdeg;%[20 20]*pxperdeg;


%C = {sprintf('pic(monkeybutt1.png, %.1f, %.1f, %.1f, %.1f)', ...
%             fix(1), fix(2), img_size(1), img_size(2))};

C = {'fix(0,0)'};
timingfile = 'tracking3.m';
userdefined_trialholder = '';


end
