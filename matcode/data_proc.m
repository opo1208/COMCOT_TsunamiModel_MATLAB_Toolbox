%this subroutine is used to output the following results
% 1. Maximum Amplitude within the entire domain
% 2. Arrival time contour at 30', 60',..., up to 180'
% 3. Inundation
% 4. Time series of snapshots for animation
% 
%  Only Work With COMCOT version 1.7
%  Last Modification on Nov 21 2008 (Xiaoming Wang)

%updated on Mar 17 2009 (Xiaoming Wang, GNS) for Gisborne Inundation;

function data_proc(startstep,endstep,step_int,grid_id)

%%set default color scale
cmax = 1.0;

%%set up default value for options
i_sel_frame = 0;
i_sel_ts = 1;
i_sel_arrive = 1;
i_sel_inundation = 1;
i_sel_velocity = 1;
i_range = 1;
int = 1;
i_map = 1;
des = '';

i_sel_frame = input('Plot Colored Frames? (0:Yes,1-No):');
if i_sel_frame == 0
    des = input('Input description of the plots:');
    cmax = input('Please input color scale (in meters):');
    i_map = input('Use Georeferenced image as a base map? (0:Yes, 1-No):');
    if i_map == 0
        mapname = input('Please input base map name:');
        tfwname = input('Please input TFW (World File) file Name:');
    end
    i_sel_velocity = input('Plot Velocity Vectors? (0:Yes,1-No):');
    if i_sel_velocity == 0
        int = input('Please input the number of grids between arrows:');
    end
    i_range = input('Change the output range of ploting? (0:Yes, 1-No):');
    if i_range == 0
        xs = input('Input the starting x coordinate:');
        ys = input('Input the starting y coordinate:');
        xe = input('Input the ending x coordinate:');
        ye = input('Input the ending y coordinate:');
    end
end
i_sel_ts = input('Extract Time history records? (0:Yes,1-No):');
i_sel_arrive = input('Obtain Arrival Time Contour? (0:Yes,1-No):');
i_sel_inundation = input('Obtain Inundation map? (0:Yes,1-No):');
dt = input('Please Input Time step size (second):');
tl = input('Please Tidal Level (meter):');

% i_sel_frame = 0
% des = 'LachlanFaultNew_PovertyBay_HighTide'
% caption = 'Wave Amp and Flow Depth - Lachlan Fault (New, HighTide)'
% cmax = 5.0
% i_map = 0.0
% mapname = 'AerialPhoto_05mRes1.jpg'
% tfwname = 'AerialPhoto_05mRes1.tfw'
% i_sel_velocity = 0
% int = 20
% i_range = 1
% i_sel_ts = 0
% i_sel_arrive = 1
% i_sel_inundation = 1
% dt = 0.6452840
% tl = 0.75;

m_ts=1;
n_ts=1;
if i_sel_ts==0
    ts_loc=load('ts_location.dat'); %ts_location is a (.)*2 matrix
    [m_ts,n_ts]=size(ts_loc)
end

% t = load('time.dat');
% Nt = length(t);
% dt = t(2)-t(1);
% k_start = t(1)/dt;
% k_end = t(Nt)/dt;

if grid_id < 10
    str_id = ['0',num2str(grid_id)];
else
    str_id = num2str(grid_id);
end
%load in bathymetry data and coordinates info output by COMCOT
disp('Loading bathymetry and coordinates information ...')
layer=load(['layer',str_id,'.dat']);
layer_x=load(['layer',str_id,'_x.dat']);
layer_y=load(['layer',str_id,'_y.dat']);

nx = length(layer_x)
ny = length(layer_y)
layer = reshape(layer,nx,ny);

[x,y]=meshgrid(layer_x,layer_y);
amp=zeros(nx,ny);

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

if i_sel_arrive == 0
    arrival_time=zeros(nx,ny);
    arrival_check=zeros(nx,ny,4);
    arrival_height=zeros(nx,ny,3);
end

%set the default output range
if i_range == 1
    xs = layer_x(1);
    ys = layer_y(1);
    xe = layer_x(nx);
    ye = layer_y(ny);
    is = 1;
    ie = nx
    js = 1;
    je = ny;
end
% find out the index of xs,ys,xe,ye
if i_range == 0
    is = 1;
    ie = 1;
    js = 1;
    je = 1;
    for i = 1:nx-1
        if xs>=layer_x(i) & xs<layer_x(i+1)
            is = i;
        end
        if xe>=layer_x(i) & xe<layer_x(i+1)
            ie = i
        end
    end
    for j = 1:ny-1
        if ys>=layer_y(j) & ys<layer_y(j+1)
            js = j;
        end
        if ye>=layer_y(j) & ye<layer_y(j+1)
            je = j
        end
    end
%     des = [des,'_Zoom'];
end

%%Load in base map (for Gisborne Project)
if i_sel_frame == 0 & i_map == 0
    disp('Loading Geo-Referenced Image as Base map...')
%     mapname
%     tfwname
    handle = imread(mapname);
    [image_ny,image_nx,itmp] = size(handle);
    %get Georeferencing information
    TFW = load(tfwname);
    A = TFW(1);
    B = TFW(2);
    C = TFW(3);
    D = TFW(4);
    E = TFW(5);
    F = TFW(6);
    dx = A;
    dy = D;
    figure_xs = E;
    figure_xe = figure_xs+image_nx*dx;
    figure_ye = F;
    figure_ys = figure_ye + image_ny*dy;
    image(handle,'CDataMapping','scaled','XData',[figure_xs figure_xe],'YData',[figure_ye figure_ys]);
end
%

N = round((endstep - startstep)/step_int)+1;
% %define matrix region to store the data of the region to plot

timeseries=zeros(N,m_ts);

filename_head = ['z_',str_id,'_'];
filenameu_head = ['m_',str_id,'_'];
filenamev_head = ['n_',str_id,'_'];
time = startstep; % start time
for k=1:N
%     %---------------find characters of an output data filename-----------------------
    step = time;
    if step < 10
        filename_minute = ['00000',num2str(step)];
    end
    if step >=10 & step < 100
        filename_minute = ['0000',num2str(step)];
    end
    if step >=100 & step < 1000
        filename_minute = ['000',num2str(step)];
    end

    if step >=1000 & step < 10000
        filename_minute = ['00',num2str(step)];
    end
    if step >=10000 & step < 100000
        filename_minute = ['0',num2str(step)];
    end
    if step >=100000
        filename_minute = [num2str(step)];
    end
%     %----------obtain the full filename with extension name---------------
     filename = [char(filename_head),num2str(filename_minute),'.dat']
     if i_sel_velocity == 0
        filenameu = [char(filenameu_head),num2str(filename_minute),'.dat']
        filenamev = [char(filenamev_head),num2str(filename_minute),'.dat']
     end
   
%     %---------open the file and fetch data-------------------------------
    fid = fopen(char(filename));
    a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
    fclose(fid);
    region = reshape(a,nx,ny);
    clear a
    
    if i_sel_velocity == 0
        fid = fopen(char(filenameu));
        a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
        fclose(fid);
        xflux = reshape(a,nx,ny);
        clear a    
        fid = fopen(char(filenamev));
        a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
        fclose(fid);
        yflux = reshape(a,nx,ny);
        clear a
    end
%     %Calculate max amplitude within the entire domain/////////////////////
    for i=1:nx
        for j=1:ny
            if amp(i,j)<region(i,j)
                amp(i,j)=region(i,j);
            end
            if i_sel_arrive==0
                if layer(i,j)>0 & region(i,j)>=0.01 % & region(im1,j)>=0.005 & region(ip1,j)>=0.005 & region(i,jm1)>=0.005 & region(i,jp1)>=0.005
% %                 arrival_check(i,j,3)=1;
                    arrival_check(i,j,4)=1;
% %                 arrival_height(i,j,3)=region(i,j);
                end
% %             if arrival_check(i,j,1)==1 & arrival_check(i,j,2)==1 & arrival_check(i,j,3)==1
                if arrival_check(i,j,1)==1 & arrival_check(i,j,2)==1 & arrival_check(i,j,3)==1 & arrival_check(i,j,4)==1
% %               if arrival_height(i,j,2)>arrival_height(i,j,1) & arrival_height(i,j,3)>arrival_height(i,j,2)
                    arrival_time(i,j)=1;
                end
            end
        end
    end
    
    if i_sel_arrive==0
        arrival_check(:,:,1)=arrival_check(:,:,2);
        arrival_check(:,:,2)=arrival_check(:,:,3);
        arrival_check(:,:,3)=arrival_check(:,:,4);
        arrival_height(:,:,1)=arrival_height(:,:,2);
        arrival_height(:,:,2)=arrival_height(:,:,3);
%         %pause
%         %calculate arrival time within the entire domain////////////////
%         %
%         %#### step number needs to be modified according to the time step
        if (step-1)*dt<1800.0 & (step)*dt>=1800.0
            save time_contour_30min.dat arrival_time -ascii;
        elseif (step-1)*dt<3600.0 & (step)*dt>=3600.0
            save time_contour_60min.dat arrival_time -ascii;
        elseif (step-1)*dt<5400.0 & (step)*dt>=5400.0
            save time_contour_90min.dat arrival_time -ascii;
        elseif (step-1)*dt<7200.0 & (step)*dt>=7200.0
            save time_contour_120min.dat arrival_time -ascii;
        elseif (step-1)*dt<9000.0 & (step)*dt>=9000.0
            save time_contour_150min.dat arrival_time -ascii;
        elseif (step-1)*dt<10800.0 & (step)*dt>=10800.0
            save time_contour_180min.dat arrival_time -ascii;
        elseif (step-1)*dt<12600.0 & (step)*dt>=12600.0
            save time_contour_210min.dat arrival_time -ascii;
        elseif (step-1)*dt<14400.0 & (step)*dt>=14400.0
            save time_contour_240min.dat arrival_time -ascii;
        elseif (step-1)*dt<16200.0 & (step)*dt>=16200.0
            save time_contour_270min.dat arrival_time -ascii;
        elseif (step-1)*dt<18000.0 & (step)*dt>=18000.0
            save time_contour_300min.dat arrival_time -ascii;
        elseif (step-1)*dt<19800.0 & (step)*dt>=19800.0
            save time_contour_330min.dat arrival_time -ascii;
        elseif (step-1)*dt<21600.0 & (step)*dt>=21600.0
            save time_contour_360min.dat arrival_time -ascii;
        end
    end

    
% %   %//// obain time series for time history plots /////////////////
    if i_sel_ts == 0
        tmp = interp2(x,y,region',ts_loc(:,1),ts_loc(:,2));
%        size(tmp)
        timeseries(k,:)=tmp';
    end

% %%% ////////Plot snapshots for animation/////////////////////////////
    if i_sel_frame==0
        if i_map == 0
            image(handle,'CDataMapping','scaled',...
                    'XData',[figure_xs figure_xe],...
                    'YData',[figure_ye figure_ys]);
            set(gca,'YDir','normal')
            hold on
            axis equal
            axis xy
            axis([xs xe ys ye])        
        end
%       %remove zero data on land (for Gisborne Project)
%       %Apply special treatment on tidal level and uplift caused by
%       earthquake
        flowdepth = region;
        
        for i=is:ie
            for j=js:je
                dd = region(i,j)+layer(i,j)-deform(i,j);
                ht = layer(i,j)-deform(i,j)+tl;
                if dd>0.05 & layer(i,j)-deform(i,j)<=0
                    flowdepth(i,j) = region(i,j)+layer(i,j)-deform(i,j);
                    layer(i,j) = layer(i,j)-deform(i,j);
                end
                if dd<=tl & layer(i,j)<=0 & layer(i,j)+tl>0.0
                    region(i,j) = NaN;
                    flowdepth(i,j) = NaN;
                end
                if dd<=0.05
                    region(i,j) = NaN;
                    flowdepth(i,j) = NaN;
                end
            end
        end
        
%         %end of remove zero data on land (for Gisborne Project)
%         surface(x(js:je,is:ie),y(js:je,is:ie),flowdepth(is:ie,js:je)','FaceAlpha',0.75)
        pcolor(x(js:je,is:ie),y(js:je,is:ie),flowdepth(is:ie,js:je)')
        shading interp
        axis equal
        axis([xs xe ys ye])
%         colormap('default')
        caxis([-cmax cmax]);
        colorbar
%         title(caption)
                
        hold on
        contour(x(js:je,is:ie),y(js:je,is:ie),-layer(is:ie,js:je)',[0 0],'k')
      
        if i_sel_velocity == 0
            plot_arrow(region(is:ie,js:je),layer(is:ie,js:je),...
                        layer_x(is:ie),layer_y(js:je),...
                        xflux(is:ie,js:je),yflux(is:ie,js:je),int)
        end
        
        clear region
%         plot_region(2)
%         plot_region(3)
% %...    Add timer
        t_sec=step*dt;
% %         clock=sec2hms(t);
        clock = t_sec;
        clock_hrs=floor(t_sec/3600);
        if clock_hrs<1
            hour='00';
        elseif clock_hrs>=1 & clock_hrs <=9
            hour=['0',num2str(clock_hrs)];
        else
            hour=[num2str(clock_hrs)];
        end
        clock_min=floor((t_sec-clock_hrs*3600)/60);
        if clock_min<1
            minute='00';
        elseif clock_min>=1 & clock_min <=9
            minute=['0',num2str(clock_min)];
        else
            minute=[num2str(clock_min)];
        end
        clock_sec=floor(t_sec-clock_hrs*3600-clock_min*60);
        if clock_sec<1
            sec='00';
        elseif clock_sec>=1 & clock_sec <=9
            sec=['0',num2str(clock_sec)];
        else
        sec=[num2str(clock_sec)];
        end

        timer=[hour,':',minute,':',sec];
        x_pos=(xe-xs)*0.5+xs;
        y_pos=(ye-ys)*0.97+ys;
        text(x_pos,y_pos,timer,'FontSize',13,'FontWeight','bold',...
            'Color','b','HorizontalAlignment','center',...
            'BackgroundColor','w','EdgeColor','r')
%         %////end of timer

        figurename = ['Figure_',des,'_',char(filename_head),...
                        num2str(filename_minute),'.png'];
        print('-dpng', figurename);
%         print('-dpng', figurename);
%         imwrite(gcf,figurename,'png','Author','Xiaoming Wang','Copyright','GNS','Software','COMCOTV1.7')
%         imwrite(gcf,figurename,'png')
        hold off
    end
% %%%///// End of Plotting Frames /////////////////////////////////    
    %Go to next step
    time = time + step_int;
end
% % save inundation.dat inundation -ascii;
save max_amp.dat amp -ascii;
if i_sel_inundation==0
    inundation=zeros(nx,ny);
    for i=1:nx
        for j=1:ny
            if max_amp(i,j)+layer(i,j)<=0.05
                inundation(i,j)=max_amp(i,j)+layer(i,j);
            end
        end
    end
    save inundation_map.dat inundation -ascii;
end

if i_sel_ts==0
    save timeseries.dat timeseries -ascii;
end
clear all;
