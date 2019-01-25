close all
clear all
fclose all
 
layerid=1;
nonlinear=0;
first=80;
step=2;
last=200;
dt=0.01;
autocaxis = 0; 
% 0: manual. 
% 1: based on max elevation of first plot. 
% 2: based on max elevation of each plot.
% 3: wave height min to max 
minn=-2;
maxx=2;
filedir='';
plotgauge=0;
intervalx = [];
intervaly = [];

%intervalx = [118, 123];
%intervaly = [20, 27];
%intervalx = [115, 128];
%intervaly = [17, 28];
savetif = 0;


%% 

if exist(['layer' num2str(layerid,'%02d') '_xs.dat'],'file')...
        && exist(['layer' num2str(layerid,'%02d') '_ys.dat'],'file')
    xgd=load(['layer' num2str(layerid,'%02d') '_xs.dat']);
    ygd=load(['layer' num2str(layerid,'%02d') '_ys.dat']);
    if isempty(xgd) || isempty(ygd)
        xgd=load(['layer' num2str(layerid,'%02d') '_x.dat']);
        ygd=load(['layer' num2str(layerid,'%02d') '_y.dat']);
    end
else
    xgd=load(['layer' num2str(layerid,'%02d') '_x.dat']);
    ygd=load(['layer' num2str(layerid,'%02d') '_y.dat']);
end

nx=length(xgd);
ny=length(ygd);

fid2 = fopen(['layer' num2str(layerid,'%02d') '.dat'],'r');
layer=fscanf(fid2,'%f');
dep=reshape(layer,nx,ny);
dep=-dep';
groundmask1 = dep<=9000;
groundmask2 = dep>=0;
ground=groundmask2;
land=dep.*ground;

if( plotgauge==1 && exist('ts_location.dat','file') )
    tsloc=load('ts_location.dat');
    if(exist('ts_name.dat','file'))
        tsname=textread('ts_name.dat','%s');
    end
end

cm=load('cm3.txt');

if exist('filedir','var') && ~isempty(filedir)
    cd(filedir)
end



%% Plot Data

fst=first/dt;
stp=step/dt;
lst=last/dt;

ny1=round(length(ygd)/2)


%for stpi=[8600 10000 11400 12800]
for stpi = fst:stp:lst
    stpi
    fid=fopen(['z_' num2str(layerid,'%02d') '_' num2str(stpi,'%06d') '.dat']);

    z=fscanf(fid,'%f');
    size(z);
    dd=reshape(z,nx,ny);
    zeta=dd';
    zeta1=fliplr(zeta)/20;
    dep1=fliplr(dep)/20;
    xgd1=(xgd-500)/20;

    clf

    plot(xgd1,zeta1(ny1,:),'k','linewidth',2);
    hold on
    plot(xgd1,dep1(ny1,:),'r','linewidth',2);
    
    axis([-5 30 -0.03 0.07])
    box on
    xlabel(['x/h_0']);
    ylabel(['\zeta/h_0']);
    title(['Run-up Validation. COMCOT vs EXP (Synolakis, 1987). a/h_0=0.0185'])
    text(13, 0.04, ['T=t*sqrt(g/h_0)=' num2str(stpi/286.6667,'%02g')]) 
    
    fn=['z_' num2str(layerid,'%02d') '_' num2str(stpi,'%06d') '.png'];
    print('-dpng',fn);
end

fclose all
