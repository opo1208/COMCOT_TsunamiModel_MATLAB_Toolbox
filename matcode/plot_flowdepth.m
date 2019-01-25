%This script is used to plot maximum flow depth distribution during inundation.
%This script only works for COMCOT version 1.7, needs modification for
%earlier versions.
%Note: change cmax as necessary to yield a better plot
%Last revise: Jan 27 2009 by Xiaoming Wang

function plot_flowdepth(id)

cmax = 5; %change to adjust color scale
tl = 0.0;

fname = input('Input max amplitude data file name:');
fnames = input('Input Scenario Event name:');
tl = input('Please input tidal level:');
% fname = 'etamax_layer01.dat'
%load bathymetry data

if id < 10
    str_id = ['0',num2str(id)];
end
if id >= 10 & id<100
    str_id = num2str(id);
end
% str_id
disp('Loading Bathymetry Data into Memory...')
layer = load(['layer',str_id,'.dat']);
layer_x = load(['layer',str_id,'_x.dat']);
layer_y = load(['layer',str_id,'_y.dat']);
[x,y] = meshgrid(layer_x,layer_y);

nx = length(layer_x);
ny = length(layer_y);

depth = reshape(layer,nx,ny);

clear layer

%load seafloor deformation
disp('Loading Seafloor Deformation data ...')
fid = fopen('ini_surface.dat');
a = fscanf(fid,'%g',inf);
fclose(fid)
lg_x = load('layer01_x.dat');
lg_y = load('layer01_y.dat');
nx_lg = length(lg_x);
ny_lg = length(lg_y);
deform1 = reshape(a,nx_lg,ny_lg);
clear a
[x_lg,y_lg] = meshgrid(lg_x,lg_y);
deform = interp2(x_lg,y_lg,deform1',x,y);
deform = deform';
size(deform)
clear deform1
clear lg_x
clear lg_y
clear x_lg
clear y_lg



%load water surface elevation data
disp('Loading Water Surface Elevation Data ...')
fid = fopen(fname);
a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
fclose(fid);

max_amp = reshape(a,nx,ny);
clear a
disp('Determining Flow Depth due to Inundation ...')
flowdepth = zeros(nx,ny);
for i=1:nx
    for j=1:ny
        dd = depth(i,j)+max_amp(i,j)-deform(i,j);
        ht = tl+(depth(i,j)-deform(i,j)); %still water depth caused by hightide (originally land)
        if dd>0.05 & depth(i,j)-deform(i,j)<=0.0
            flowdepth(i,j)=depth(i,j)-deform(i,j)+max_amp(i,j);
        end
        if dd>tl & depth(i,j)-deform(i,j)+tl<=0.0
            flowdepth(i,j)=depth(i,j)-deform(i,j)+max_amp(i,j);
        end        
        if dd<=tl & depth(i,j)<=0.0 & depth(i,j)+tl>0.0
            flowdepth(i,j)=0.0;
        end
        if dd <= 0.05
            flowdepth(i,j) = 0.0;
        end        
    end
end
clear max_amp

% [x,y] = meshgrid(layer01_x,layer01_y);

pcolor(x,y,flowdepth')
shading flat
caxis([0 cmax])
axis equal
axis tight
% contourcmap([0:cmax/20:cmax],'jet','colorbar','on','location','vertical')
xlabel('X coordinate')
ylabel('Y coordinate')

% mycmap = get(gcf,'Colormap'); 
% save('MyColormaps','mycmap')
% load('MyColormaps','mycmap')
% set(gcf,'Colormap',mycmap)
% a = reshape(flowdepth,nx*ny,1);
% clear flowdepth

hold on
contour(x,y,-depth',[0 0],'k')
axis([layer_x(1) layer_x(nx) layer_y(1) layer_y(ny)])
colormapeditor

figurename = ['Figure_FlowDepth_Layer',str_id,'_',fnames];
print('-dpng', figurename);

% save flowdepth in XYZ-format
disp('Writing data into a XYZ-format file ...')
NN = nx*ny;

bathymetry = zeros(NN,3);

iflip = 0;  %iflip = 0: write from south to north; 1 - write data from north to south

if iflip == 1
   data = reshape(a,nx,ny);
   clear a
   size(data)
   dataflip = flipud(data);
   size(dataflip)
   clear data
   
   layer_y = flipud(layer_y);
   for j = 1:ny
       ks = (j-1)*nx+1;
       ke = j*nx;
       bathymetry(ks:ke,1) = layer_x;
       bathymetry(ks:ke,2) = layer_y(j);
       bathymetry(ks:ke,3) = dataflip(1:nx,j);
   end
end

if iflip == 0
%    bathymetry(:,3) = a;
    for j = 1:ny
        ks = (j-1)*nx+1;
        ke = j*nx;
        bathymetry(ks:ke,1) = layer_x;
        bathymetry(ks:ke,2) = layer_y(j);
        bathymetry(ks:ke,3) = flowdepth(:,j);
    end
end
clear flowdepth

fid = fopen(['FlowDepth_Layer',str_id,'_',fnames,'.xyz'],'w+');
%write dimension of slide data slide(nx,ny,nt)
%write x coordinates
for i=1:NN
    fprintf(fid,'%17.6f %17.6f %8.3f\n',bathymetry(i,1),bathymetry(i,2),bathymetry(i,3));
end
fclose(fid)







