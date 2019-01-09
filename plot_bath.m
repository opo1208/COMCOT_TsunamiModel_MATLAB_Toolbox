clc; clear; fclose all; close all;

% 
layerid = 1;

% load COMCOT domain
xgd=load(['../layer' num2str(layerid,'%02d') '_x.dat']);
ygd=load(['../layer' num2str(layerid,'%02d') '_y.dat']);

% grid number of x and y
nx=length(xgd);
ny=length(ygd);

% x and y domain
domain_x = [min(xgd) max(xgd)];
domain_y = [min(ygd) max(ygd)];

% load bathymetry
fid2  = fopen(['../layer' num2str(layerid,'%02d') '.dat'],'r');
layer = fscanf(fid2,'%f');
dep   = reshape(layer,nx,ny); dep = -dep';

%
h_ocean = dep;
h_ocean(dep>0) = nan;

% shallow water region
h_shallow = h_ocean;
h_shallow(dep<-10) = nan;

% plot
% pcolor(xgd,ygd,dep); shading flat; hold on;
pcolor(xgd,ygd,h_ocean); shading flat; hold on;
% pcolor(xgd,ygd,h_shallow); shading flat; hold on;

contour(xgd,ygd,dep,[0 0], 'k');

colormap(jet); colorbar;

caxis([-5000 0]);

box on; set(gca,'Layer','top');