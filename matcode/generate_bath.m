clc; clear; fclose all; close all;

StillWaterDepth = -10.0;

x_start = 0.0;
x_end = 1000.0;

y_start = 0.0;
y_end = 10.0;

dx = 1.0;
dy = 1.0;

x = x_start:dx:x_end;
y = y_start:dy:y_end;

nx = length(x);
ny = length(y);

OutputFile = 'flat_bottom_10m.xyz';

fid = fopen(OutputFile,'w');


for i = 1:nx
    for j = 1:ny
        
        fprintf(fid,' %7.2f  %7.2f  %7.2f\n',x(i), y(j),StillWaterDepth);
        
        
    end
end

fclose(fid);