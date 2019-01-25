clear all
close all
%----- load gauges files -----
gaugenum = 'all';
onland=0;
realgauge=0;
plotmax=1;
savetif = 0;
starttime = 0;  % second
endtime = 3600; % second
auto_ylim = 1; % auto adjust ylim. 0:close, 1: open
maxx=0; % set minn and maxx the same to close this usement
minn=0;
plotth = 0;
% th_good=[1,2,3,4,5,8,11,12,19,22,24,27,28,31,34,35,37,39,46,51,53,54];
% ts_good=[1,2,3,4,15,21,53];
% filedir = '8.0_upperbound';

if exist('filedir','var')
    cd(filedir)
end

% load time file
time=load('time.dat');

% load location file
ts_gauges=load('ts_location.dat');
[ts_num,coor]=size(ts_gauges);
maxx_ts=zeros(ts_num,1);
maxx_th=zeros(ts_num,1);

% load gauge name
ggfid = fopen('ts_name.dat');
gg = textscan(ggfid,'%s');
gname = gg{1};
fclose(ggfid);
if ~isempty(findstr('all',gaugenum))
    gaugenum=1:ts_num;
end
if realgauge==1
    cd data
    
    realdata = zeros((endtime-starttime)/60+1,length(gname));
    gtime=starttime:60:endtime;
    gtime=reshape(gtime,length(gtime),1);
    for ri = gaugenum
        if strcmp(gname{ri}(length(gname{ri})-1),'_')
            if exist([gname{ri}(1:length(gname{ri})-2) '.dat'],'file')
                temp = load([gname{ri}(1:length(gname{ri})-2) '.dat']);
                if ~isequal(temp(temp(:,1)>=starttime & temp(:,1)<=endtime,1),gtime)
                    fprintf('Problem! Required time series data does not included in gauges: %d\n', ri)
                    return
                end
                realdata(:,ri) = temp(temp(:,1)>=starttime & temp(:,1)<=endtime,2);
            else
                realdata(:,ri) = nan;
            end
        elseif strcmp(gname{ri}(length(gname{ri})-3:end),'Buoy')
            if exist([gname{ri}(1:length(gname{ri})-5) '.dat'],'file')
                temp = load([gname{ri}(1:length(gname{ri})-5) '.dat']);
                if ~isequal(temp(temp(:,1)>=starttime & temp(:,1)<=endtime,1),gtime)
                    fprintf('Problem! Required time series data does not included in gauges: %d\n', ri)
                    return
                end
                realdata(:,ri) = temp(temp(:,1)>=starttime & temp(:,1)<=endtime,2);
            else
                realdata(:,ri) = nan;
            end
        else
            if exist([gname{ri} '.dat'],'file')
                temp = load([gname{ri} '.dat']);
                if ~isequal(temp(temp(:,1)>=starttime & temp(:,1)<=endtime,1),gtime)
                    fprintf('Problem! Required time series data does not included in gauges: %d\n', ri)
                    return
                end
                realdata(:,ri) = temp(temp(:,1)>=starttime & temp(:,1)<=endtime,2);
            else
                realdata(:,ri) = nan;
            end
        end
    end
    cd ..
end
% COMCOT 1.7 ts file
ts=[];
th=[];

for tsn=gaugenum
    ts(:,tsn)=load(['ts_record' num2str(tsn,'%04d') '.dat']);
    maxx_ts(tsn)=max(ts(:,tsn));
    if plotth==1
        th(:,tsn)=load(['th_record' num2str(tsn,'%04d') '.dat']);
        maxx_th(tsn)=max(th(:,tsn));
    end
end



% plot figures
for gi=gaugenum
    if plotth == 1
        figure
        plot(time(time>=starttime & time<=endtime)/60,th(time>=starttime & time<=endtime,gi),'b','linewidth',1)
        hold on
        if realgauge==1
            plot(gtime/60,realdata(:,gi),'k')
        end
        if minn ~= maxx
            ylim([minn maxx])
        end
        if auto_ylim == 1
            ylim([-ceil(max((ylim))*2)/2 ceil(max((ylim))*2)/2])
            %ylim([-ceil(max(abs(ylim))*2)/2 ceil(max(abs(ylim))*2)/2])
        end
        xlim([starttime/60 endtime/60])
        xlabel('time (min)')
        ylabel('Free-Surface Elevation (m)')
        set(gca,'fontsize',16)
        set(get(gca,'ylabel'),'fontsize',16)
        set(get(gca,'xlabel'),'fontsize',16)
%         set(gca,'dataaspectr',[100 1 1])
        if realgauge==1
            legend('Simulated result','Observed data')
        end
        title([gname{gi}],'interpreter','none')
        print('-dpng',[num2str(gi,'%02d') '_' gname{gi} '_th.png'])
    end
    
    figure
    plot(time(time>=starttime & time<=endtime)/60,ts(time>=starttime & time<=endtime,gi),'k','linewidth',1)
    hold on
    if realgauge==1
        plot(gtime/60,realdata(:,gi),'--k')
    end
    if minn ~= maxx
        ylim([minn maxx])
    end
    if auto_ylim == 1
        ylim([-ceil(max(abs(ylim))*2)/2 ceil(max(abs(ylim))*2)/2])
    end
    xlim([starttime/60 endtime/60])
    xlabel('time (min)')
    ylabel('Free-Surface Elevation (m)')
    set(gca,'fontsize',16)
    set(get(gca,'ylabel'),'fontsize',16)
    set(get(gca,'xlabel'),'fontsize',16)
%     set(gca,'dataaspectr',[100 1 1])
    if realgauge==1
        legend('Simulated result','Observed data')
    end
    title([gname{gi}],'interpreter','none')
    print('-dpng',[num2str(gi,'%02d') '_' gname{gi} '_ts.png'])
    if savetif == 1
        print('-dtiff',[num2str(gi,'%02d') '_' gname{gi} '_ts.tif'],'-r300')
    end
    close all
end

skip=ones(1,length(maxx_ts));
%skip(6)=nan;
for ii= 1: length(maxx_ts)
    if std(ts(2:length(ts),ii)) <0.0001
        skip(ii)=nan;
        ii
    end
end
        
maxx_ts=maxx_ts.*skip';


if plotmax == 1
    figure
    if plotth == 1
        plot(gaugenum,maxx_th(gaugenum),'*k')
    end
    hold on
    plot(gaugenum,maxx_ts(gaugenum),'*r')
    xlim([-inf inf])
%     ylim([0 1.5])
    set(gca,'xtick',gaugenum)
    set(gca,'xticklabel',{gname{gaugenum}})
    xhd=xticklabel_rotate('',45);
    set(xhd,'interpreter','none','fontsize',10)
    set(gca,'fontsize',16)
    set(get(gca,'ylabel'),'fontsize',16)
    set(get(gca,'xlabel'),'fontsize',16)
    grid on
    title('The Largest Wave Height')
%     xlabel('gauge number')
    ylabel('wave height (m)')
    print('-dpng','gau_max.png')
    saveas(gcf, 'gau_max.fig')
    print('-deps','gau_max')
    save('ts_max.txt','maxx_ts','-ascii')
    if plotth == 1
        save('th_max.txt','maxx_th','-ascii')
    end
end

mkdir('ts')

if plotth ==1
    mkdir('th')
    if exist('th_good','var')
        mkdir('result')
        for hi=intersect(th_good,gaugenum)
            copyfile([ num2str(hi,'%02d') '_*_th.png'],'result')
        end
    end
    movefile('*_th.png','th')
end

if exist('ts_good','var')
    for si=intersect(ts_good,gaugenum)
        copyfile([ num2str(si,'%02d') '_*_ts.png'],'result')
    end
end

movefile('*_ts.png','ts')

% movefile('th','gauges_image')
% movefile('ts','gauges_image')
% movefile('result','gauges_image')

if plotmax == 1
    dirname='gauges_image';
    mkdir(dirname)
    movefile('gau_max.png',dirname)
     movefile('gau_max.fig',dirname)
end

if exist('filedir','var')
    cd ..
end
