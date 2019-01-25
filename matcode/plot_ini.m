%This script is used to plot the water suface displacement at t = 0.0,
% i.e., z_01_000000.dat output by COMCOT;
%The Script only works for COMCOT version1.7;
%Last Revise: Nov21 2008 by Xiaoming Wang


function plot_ini()

layer = load('layer01.dat');
layer_x = load('layer01_x.dat');
layer_y = load('layer01_y.dat');
[x,y] = meshgrid(layer_x,layer_y);

nx = length(layer_x);
ny = length(layer_y);

depth = reshape(layer,nx,ny);
clear layer
clear layer_x
clear layer_y

fid = fopen('ini_surface.dat');
a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
fclose(fid);

deform = reshape(a,nx,ny);
clear a

zmax = max(max(deform))
zmin = min(min(deform))
cmax = 0.95*max([abs(zmax) abs(zmin)])
% cmax = 5.0

for i=1:nx
   for j=1:ny
      if abs(deform(i,j))<0.005
         deform(i,j) = NaN;
      end
   end
end
pcolor(x,y,deform')
shading interp
axis equal
axis tight
caxis([-cmax cmax])
colorbar
xlabel('X Coordinate')
ylabel('Y Coordinate')
clear deform

hold on
contour(x,y,-depth',[0 0],'k')
print('-dpng', 'Figure_InitialDisplacement');






