clc; clear; fclose all; close all;

% 
layerid = 1;

% load COMCOT domain
xgd=load(['../layer' num2str(layerid,'%02d') '_x.dat']);
ygd=load(['../layer' num2str(layerid,'%02d') '_y.dat']);

% grid number of x and y
nx = length(xgd);
ny = length(ygd);

% x and y domain
domain_x = [min(xgd) max(xgd)];
domain_y = [min(ygd) max(ygd)];

% load bathymetry
fid2 = fopen(['../layer' num2str(layerid,'%02d') '.dat'],'r');
layer = fscanf(fid2,'%f');
dep = reshape(layer,nx,ny); dep = -dep';

% load gauge locations
gauge_loc = load('../ts_location.dat');

%
h_ocean = dep; h_ocean(dep>0) = nan;
h_land = dep; h_land(dep<0) = nan;

% plot
set(gcf,'units','normalized','position',[0.1 0.1 0.6 0.7],'PaperPositionMode','auto'); hold on;

pcolor(xgd,ygd,h_land); shading flat; 
colormap(gray); caxis([-1000 2000]);

contour(xgd,ygd,dep,[0 0], 'k');

for gauge_id = [1 2 3 4 7] 
    
    plot(gauge_loc(gauge_id,1),gauge_loc(gauge_id,2),'ro','MarkerFaceColor','b');
    
end

box on; set(gca,'Layer','top');

xlim([20 120]); ylim([-34 30]);

xlabel('Longitude','fontsize',12);
ylabel('Latitude','fontsize',12);
ax = gca; ax.FontSize = 12;

print('-dpng','gauge_map.png');