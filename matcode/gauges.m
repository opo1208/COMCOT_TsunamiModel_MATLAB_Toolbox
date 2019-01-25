close all
clear all

layerid=04;

%----- load gauges files -----

fst=0; % first step
lst=28800; % last step
stp=60; %step

xgd=load(['layer' num2str(layerid,'%02d') '_x.dat']);
ygd=load(['layer' num2str(layerid,'%02d') '_y.dat']);
nx=length(xgd);
ny=length(ygd);
fid2 = fopen(['layer' num2str(layerid,'%02d') '.dat'],'r');
layer=fscanf(fid2,'%f');
dep=reshape(layer,nx,ny);
dep=-dep';

dt=5;

fst=fst/dt;
lst=lst/dt;
stp=stp/dt;

% [gno,gx,gy,gg]=textread(['gno' num2str(layerid,'%02d') '.txt'],'%d%d%d%s');

ts_gauges=load('ts_location.dat');
ts_gauges=ts_gauges(42,:);
[ts_num,coor]=size(ts_gauges);

ggfid = fopen('gauges_name_english.txt');
gg = textscan(ggfid,'%s');
gg = gg{1};

gx=zeros(ts_num,1);
gy=zeros(ts_num,1);

for i=1:ts_num
    tmpx=find(abs(xgd-ts_gauges(i,1)) <= 0.501*abs(xgd(2)-xgd(1)));
    gx(i)=tmpx(1);
    tmpy=find(abs(ygd-ts_gauges(i,2)) <= 0.501*abs(ygd(2)-ygd(1)));
    gy(i)=tmpy(1);
end

com17=zeros((fst-lst)/stp+1,length(ts_num));

maxx=zeros(length(ts_num),1);
%----- files source -----

frnt=['z_' num2str(layerid,'%02d') '_'];

% pstp = now ploting step
pstp=fst;

i=0;
% cd zetafiles/
while 1
    if pstp > lst
        break;
    end
    i=i+1;
    fid=fopen([frnt num2str(pstp,'%06d') '.dat']);
    z=fscanf(fid,'%f');
    zm=reshape(z,nx,ny);

    for gi=1:size(ts_num)
        com17(i,gi)=zm(gx(gi),gy(gi));
    end

    fprintf('Loading: %4.1f%%\n', pstp/lst*100);

    pstp = pstp+stp;
    fclose all;
end
% cd ..

ts_gauges=load('ts_location.dat');
[ts_num,coor]=size(ts_gauges);
maxx_ts=zeros(1,ts_num);
ts=[];
% cd gaugefiles/
for tsn=1:ts_num
    ts(:,tsn)=load(['th_record' num2str(tsn,'%04d') '.dat']);
    maxx_ts(tsn)=max(abs(ts(:,tsn)));
end
% cd ..


%----- plot gauges -----
xx=linspace(0,lst*dt,i)/60;
for gi=1:size(ts_num)
    figure
    gauge = gg{gi};
    plot(xx,com17(:,gi),'.k');
    hold on
    plot((1:length(ts))/60*5,ts(:,42),'r');
    maxx(gi)=max(abs(com17(:,gi)));
    ylim([-0.5 0.5])
    xlim([0 inf])
    xlabel('time (min)')
    ylabel('height (cm)')
%     set(gca,'dataaspectr',[6 1 1])
    title({['gauge: ' gg{gi}],['depth=' num2str(dep(gy(gi),gx(gi))) 'm']},'interpreter','none')
    legend('picked by output z data','output by code')
%     print('-dpng',['th_comparison_' num2str(gi,'%02d') '_' gauge '.png']);
end
gauge42=[xx',com17];
save('gauge42.txt','gauge42','-ascii')
% 
% gauge_loc=[xgd(gx),ygd(gy)];
% loc_delta=abs(ts_gauges-gauge_loc)/abs(xgd(2)-xgd(1));
% 
% fid9=fopen('th_gauges.dat','w');
% fid10=fopen('gauges_delta.dat','w');
% for i=1:length(gauge_loc)
%     fprintf(fid9,'%.4f %.4f\n',gauge_loc(i,1),gauge_loc(i,2));
%     fprintf(fid10,'%.4f %.4f\n',loc_delta(i,1),loc_delta(i,2));
% end
% fclose(fid9)

% dirname=['layer' num2str(layerid,'%02d') '_gauge_output_vs_1o7'];
% mkdir(dirname)
% movefile(['th_comparison_*_*.png'],dirname)

