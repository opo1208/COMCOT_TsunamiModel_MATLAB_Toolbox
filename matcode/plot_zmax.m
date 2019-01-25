%This script is used to plot maximum tsunami wave height distribution.
%This script only works for COMCOT version 1.7, needs modification for
%earlier versions.
%Note: change cmax necessarily to yield a better plot
%Last revise: Nov 21 2008 by Xiaoming Wang

function plot_zmax(id)

cmax = 5.0; %change to adjust color scale
figurename = 'Figure_Max_Amp_Distribution'

fname = input('Input max amplitude data file name:');
% fname = 'etamax_layer01.dat'
%load bathymetry data

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



fid = fopen(fname);
a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
fclose(fid);

max_amp = reshape(a,nx,ny);
clear a

for i=1:nx
    for j=1:ny
        if depth(i,j)+max_amp(i,j) <= 0.01
            max_amp(i,j)=0;
        end
    end
end

[x,y] = meshgrid(layer_x,layer_y);

pcolor(x,y,max_amp')
shading flat
axis equal
axis tight
contourcmap([0:cmax/20:cmax],'jet','colorbar','on','location','vertical')
xlabel('X Coordinate')
ylabel('Y Coordinate')

% mycmap = get(gcf,'Colormap'); 
% save('MyColormaps','mycmap')
% load('MyColormaps','mycmap')
% set(gcf,'Colormap',mycmap)
clear map_amp

hold on
contour(x,y,-depth',[0 0],'k')
axis([layer_x(1) layer_x(nx) layer_y(1) layer_y(ny)])
colormapeditor

print('-dpng', [figurename,'_Layer',str_id]);




