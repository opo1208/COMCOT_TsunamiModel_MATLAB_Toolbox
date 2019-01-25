%This script is used to plot the bathymetry/topgraphic data file, layer##.dat, by COMCOT
%The Script only works for COMCOT version1.7
%Last Revise: Nov21 2008 by Xiaoming Wang


function plot_bath(id)


if id < 10
    str_id = ['0',num2str(id)];
end
if id >= 10 & id<100
    str_id = num2str(id);
end
% str_id
layer = load(['layer',str_id,'.dat']);
layer_x = load(['layer',str_id,'_x.dat']);
layer_y = load(['layer',str_id,'_y.dat']);
[x,y] = meshgrid(layer_x,layer_y);

nx = length(layer_x);
ny = length(layer_y);

depth = reshape(layer,nx,ny);
clear layer
clear layer_x
clear layer_y

% fid = fopen('ini_surface.dat');
% a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
% fclose(fid);

% deform = reshape(a,nx,ny);

% zmax = max(max(depth))
zmin = min(min(depth))
zmax = max(max(abs(depth)))

% depth = -depth;

pcolor(x,y,-depth')
shading interp
axis equal
axis tight
caxis([-0.90*zmax 0.90*zmax])
colorbar
xlabel('X Coordinate')
ylabel('Y Coordinate')
hold on
contour(x,y,-depth',[0 0],'k')
print('-dpng', ['Figure_Bathymetry_layer',str_id]);






