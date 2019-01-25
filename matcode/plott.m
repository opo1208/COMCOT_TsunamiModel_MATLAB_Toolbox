close all
clear all
 
layerid=1;
nonlinear=0;
first=0;
step=2;
last=150;
dt=0.1;
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

for stpi = fst:stp:lst
    fid=fopen(['z_' num2str(layerid,'%02d') '_' num2str(stpi,'%06d') '.dat']);
    if fid == -1
        break;
    end

    clf;
    
    z=fscanf(fid,'%f');
    size(z);
    dd=reshape(z,nx,ny);
    zeta=dd';
    contour(xgd,ygd,dep, [0 0],'k','linewidth',1);
    
%     if nonlinear==1
%         zeta=zeta-land;
%     end
    
    if( exist('tsloc','var') )
        for i=1:length(tsloc)
            hold on
            plot(tsloc(i,1),tsloc(i,2),'k*')
        end
    end
    
    
    hold on
    clf
    %pcolor(xgd,ygd,zeta);
    plot(zeta(2));
    hold on
    %shading flat
    %axis square;
    xlim([xgd(1) xgd(end)])
    ylim([ygd(1) ygd(end)])
    box on
    colormap(cm);
    if stpi == fst && autocaxis == 1
        maxx = max(max(abs(zeta)));
        minn = -maxx;
    elseif autocaxis == 2
        maxx = max(max(abs(zeta)));
        minn = -maxx;
    elseif autocaxis == 3
        maxx = max(max(zeta));
        minn = min(min(zeta));
        colormap(jet);
        fprintf('max: %f\nmin: %f\n\n', maxx, minn)
    end
    caxis([minn maxx]);
    hd=colorbar;
    ylabel(hd,'(m)','fonts',16);
    xlabel('Longitude (E)')
    ylabel('Latitude (N)')
    hrs=fix(stpi*dt/3600);
    mins=fix(stpi*dt/60) - 60*hrs;
    secs=stpi*dt - 60*mins - 3600*hrs;
    set(gca,'fontsize',16)
    set(get(gca,'ylabel'),'fontsize',16)
    set(get(gca,'xlabel'),'fontsize',16)
    if first == 0 && last == 0
        title('Initial surface');
    else
        title(['\bf\fontsize{12}' int2str(hrs) '\rm\fontsize{10}hr ' '\fontsize{12}\bf' int2str(mins) '\rm\fontsize{10}min ' '\fontsize{12}\bf' int2str(secs) '\rm\fontsize{10}sec' ]);
    end
    
    if ~isempty(intervalx) && min(intervalx) ~= max(intervalx)
        if ~isempty(intervaly) && min(intervaly) ~= max(intervaly)
            axis([min(intervalx) max(intervalx) min(intervaly) max(intervaly)])
        end
    end
    
    
    fclose all;
    
    if first==0 && last ==0
        filen=0;
        filename0='ini_surface';
        filename1=filename0;
        if exist(filename1,'file')
            while exist(filename1,'file')
                filen=filen+1;
                filename1 = [filename0(1:end-4) '(' int2str(filen) ')' filename0(end-3:end)];
            end
        end
        print('-dpng',filename1);
        if savetif == 1
            print('-dtiff',filename1,'-r300');
        end
        
    else
        print('-dpng',[ 'layer' num2str(layerid,'%02d') '_' num2str(stpi*dt,'%06d') '.png']);
        if savetif == 1
            print('-dtiff',[ 'layer' num2str(layerid,'%02d') '_' num2str(stpi*dt,'%06d') '.tif'],'-r300');
        end
    end
    
end

if first == 0 && last == 0
    
else
    dirname=['layer' num2str(layerid,'%02d') '_image'];
    mkdir(dirname)
    movefile([ 'layer' num2str(layerid,'%02d') '_*.png'],dirname)
    if savetif == 1
        movefile([ 'layer' num2str(layerid,'%02d') '_*.tif'],dirname)
    end
end

if exist('filedir','var') && ~isempty(filedir)
    cd ..
end