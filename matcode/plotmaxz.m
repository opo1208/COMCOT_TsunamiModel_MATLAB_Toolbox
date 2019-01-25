close all
clear all

for kk = [1 2 3]
kk
close all;

layerid=kk;
nonlinear=0;

autocaxis = 0; 
% 0: manual. 
% 1: based on max elevation
% 2: wave height min to max 
minn=0;
maxx=2;
plotgauge=0;
% filedir='';

intervalx = [];
intervaly = [];

dt=1;

if( plotgauge==1 && exist('ts_location.dat','file') )
    tsloc=load('ts_location.dat');
    if(exist('ts_name.dat','file'))
        tsname=textread('ts_name.dat','%s');
    end
end

% cm=load('cm_max.txt');
xgd=load(['layer' num2str(layerid,'%02d') '_x.dat']);
ygd=load(['layer' num2str(layerid,'%02d') '_y.dat']);

nx=length(xgd);
ny=length(ygd);

fid2 = fopen(['layer' num2str(layerid,'%02d') '.dat'],'r');
layer=fscanf(fid2,'%f');
dep=reshape(layer,nx,ny);
dep=-dep';
fclose(fid2);
groundmask1 = dep<=1000;
groundmask2 = dep>=0;
ground=groundmask2;
land=dep.*ground;


for mm = [0.1:0.1:0.9 1:20];

clf

minn=0;
maxx=mm;

if exist('filedir','var')
    cd(filedir)
end
fid1 = fopen(['zmax_layer' num2str(layerid,'%02d') '.dat'],'r');
a = fscanf(fid1,'%g',inf); % write all data into a column of matrix a.
fclose(fid1);
mxz = reshape(a,nx,ny);
mxz=mxz';

contour(xgd,ygd,dep, [0 0],'k','linewidth',0.3);
hold on

pcolor(xgd,ygd,mxz);
hold on
shading flat
axis image;
box on
if autocaxis == 1
    maxx = max(max(abs(mxz)));
    minn = -maxx;
%     fprintf('max: %f\nmin: %f\n\n', maxx, minn)
elseif autocaxis == 2
    maxx = max(max(mxz));
    minn = min(min(mxz));
    colormap(jet);
    fprintf('max: %f\nmin: %f\n\n', maxx, minn)
end
caxis([minn maxx]);
colorbar;
colormap(jet);
xlabel('Longitude (E)')
ylabel('Latitude (N)')
set(gca,'fontsize',16)
set(get(gca,'ylabel'),'fontsize',16)
set(get(gca,'xlabel'),'fontsize',16)

if ~isempty(intervalx) && min(intervalx) ~= max(intervalx)
    if ~isempty(intervaly) && min(intervaly) ~= max(intervaly)
        axis([min(intervalx) max(intervalx) min(intervaly) max(intervaly)])
    end
end

% title('Maximum water elevation');
if( exist('tsloc','var') )
    for i=1:length(tsloc)
        hold on
        plot(tsloc(i,1),tsloc(i,2),'k*')
    end
end

dirname='maxwave';
mkdir(dirname)
cd(dirname)
filen=0;
filename0=[ 'layer' num2str(layerid,'%02d') '_maxwave.png'];
filename1=filename0;
if exist(filename1,'file')
    while exist(filename1,'file')
        filen=filen+1;
        filename1 = [filename0(1:end-4) '(' int2str(filen) ')' filename0(end-3:end)];
    end
end

print('-dpng',filename1, '-r500');

cd ..
if exist('filedir','var')
    cd ..
end

end
clear a; clear dep; clear ground; clear groundmask1; clear groundmask2;
clear land; clear layer; clear maxz; clear nx; clear ny;
clear xgd; clear ygd;
end
