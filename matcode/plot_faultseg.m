%This script is used to plot the seafloor deformation file, deform_segXX.dat, by COMCOT
%The Script is designed to plot output of multiple fault planes
%The Script only works for COMCOT version1.7
%Last Revise: DEC30 2008 by Xiaoming Wang


function plot_faultseg(id)

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

if id<10
    id_str = ['0', num2str(id)];
else
    id_str = num2str(id);
end
filename = ['deform_seg',id_str];
fid = fopen([filename,'.dat']);
a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
fclose(fid);

deform = reshape(a,nx,ny);
clear a

zmax = max(max(deform))
zmin = min(min(deform))
cmax = 0.95*max([abs(zmax) abs(zmin)])

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
figurename = ['Figure_SeafloorDsiplacement_','Seg',id_str];
print(gcf,'-dpng', figurename);






