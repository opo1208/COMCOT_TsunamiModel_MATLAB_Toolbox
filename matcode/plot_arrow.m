%this function is designed to get the formatted data for the result data files created by Tsunami program
%and store this in matrix format.
%xs,ys,xe,ye are used to defined the region (No. of start and end grid) to plot: lower-left corner (xs,ys),upper-right corner (xe,ye)
%nx,ny: dimensions of the domain in x and y direction
%startstep: starting step number. It should be the step number corresponding the first output data file. 
%           For the above example, the first file is "z_01_000010.dat", then startstep is 10;
%endstep: ending step number. It should be the step number corresponding the last output data file. 
%         For example, if the last file is "z_01_001000.dat", then endstep is 1000;
%step_int: the step intervals between two sequent output data files. For
%          example, for two sequent files, z_01_000100.dat and z_01_000110.dat, the
%          step interval is 10

%updated on mar17 2009 (Xiaoming Wang): add average over 5 neighboring
%grids;

function plot_arrow(layer,depth,layer_x,layer_y,xflux,yflux,int)
%clear all;
%close all;
%average over int grids
% int = 10;



nx = length(layer_x);
ny = length(layer_y);

layer_xs = layer_x(1:int:nx);
layer_ys = layer_y(1:int:ny);

h = zeros(nx,ny);
u = zeros(nx,ny);
v = zeros(ny,ny);

h = depth + layer;

for i = 1:nx
    for j = 1:ny
        h(i,j) = depth(i,j) + layer(i,j);
        if h(i,j)>0.05
            u(i,j) = xflux(i,j)/h(i,j);
            v(i,j) = yflux(i,j)/h(i,j);
        end
    end
end

 
[x,y]=meshgrid(layer_x,layer_y);

%average
u_mean = u;
v_mean = v;
N = floor(int/2);
for i = 1+int:int:nx-int
    for j = 1+int:int:ny-int
        if abs(u(i,j))>0
            u_mean(i,j) = mean(mean(u(i-N:i+N,j-N:j+N)));
        end
        if abs(v(i,j))>0
            v_mean(i,j) = mean(mean(v(i-N:i+N,j-N:j+N)));
        end
    end
end

scale = 2;
% quiver(x(1:int:ny,1:int:nx),y(1:int:ny,1:int:nx),u(1:int:nx,1:int:ny)',v(1:int:nx,1:int:ny)',scale)
quiver(x(1:int:ny,1:int:nx),y(1:int:ny,1:int:nx),...
        u_mean(1:int:nx,1:int:ny)',v_mean(1:int:nx,1:int:ny)',scale)


