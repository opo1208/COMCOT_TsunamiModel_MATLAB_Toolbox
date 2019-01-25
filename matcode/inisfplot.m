close all
clear all

layerid=1;

xgd=load(['layer' num2str(layerid,'%02d') '_x.dat']);
ygd=load(['layer' num2str(layerid,'%02d') '_y.dat']);
layername=['layer' num2str(layerid,'%02d') '.dat'];
nx=length(xgd);
ny=length(ygd);

cm=load('cm3.txt');
fid2 = fopen(layername,'r');
layer=fscanf(fid2,'%f');
dep=reshape(layer,nx,ny);
dep=-dep';

fid=fopen('ini_surface.dat');

z=fscanf(fid,'%f');
dd=reshape(z,nx,ny);
zeta=dd';

figure
contour(xgd,ygd,dep, [0 0],'k','linewidth',0.3);
hold on
% pcolor(xgd,ygd,dep)
hold on
shading flat
pcolor(xgd,ygd,zeta);
hold on
shading flat
axis image;
maxx=max(max(abs(zeta)));
caxis([-2 2])
box on
colorbar
colormap(cm)
% print('-dpng','inisf')
% axis([131 135 -2 1])
xlabel('Longitude (E)')
ylabel('Latitude (N)')
title 'Initial Free-Surface Elevation'
print('-dpng','inisf', '-r500')
fclose all;
