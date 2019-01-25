%This script is used to plot the seafloor deformation file, deform_segXX.dat, by COMCOT
%xyz deformation data will be overlaid on top of Geo-referenced image
%The Script is designed to plot output of multiple fault planes
%The Script only works for COMCOT version1.7
%Created on DEC30 2008 by Xiaoming Wang
%updated on Mar 20 2009 by Xiaoming Wang, add support on geo-referenced
%image;

function plot_deform()

mapname = input('Please input base map name:');
tfwname = input('Please input TFW (World File) file Name:');
deform_name = input('Please input xyz deformation file name:');
des = input('Please a short description on the deformation:');

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
axis xy
hold on

%processing xyz deformation file
xyz = load(deform_name);
[m,n] = size(xyz);

x0 = xyz(1,1)
y0 = xyz(1,2)
nx = 0;
ny = 0;
for i = 1:m
    if xyz(i,1) == x0
        ny = ny+1;
    end
    if xyz(i,2) == y0
        nx = nx+1;
    end
end

nx
ny

i_do = 0;
if abs(nx*ny - m)>0
    i_do = 1;
    disp('The xyz data is not gridded')
end

X = zeros(nx,ny);
Y = zeros(ny,ny);

if i_do == 0
    if xyz(1,1)==xyz(2,1)
        X = reshape(xyz(:,1),ny,nx);
        Y = reshape(xyz(:,2),ny,nx);
        Z = reshape(xyz(:,3),ny,nx);
        %processing deformation data
        alphadata = Z;
        for i = 1:ny
            for j = 1:nx
%                 if abs(Z(i,j))<0.01
%                     Z(i,j) = NaN;
%                 end
                alphadata(i,j) = Z(i,j);
                if alphadata(i,j)<0
                    alphadata(i,j) = -alphadata(i,j);
                end
            end
            
        end
    end

    if xyz(1,2)==xyz(2,2)
        X = reshape(xyz(:,1),nx,ny);
        Y = reshape(xyz(:,2),nx,ny);
        Z = reshape(xyz(:,3),nx,ny);
        %processing deformation data
        alphadata = Z;
        for i = 1:nx
            for j = 1:ny
%                 if abs(Z(i,j))<0.01
%                     Z(i,j) = NaN;
%                 end
                alphadata(i,j) = Z(i,j);
                if alphadata(i,j)<0
                    alphadata(i,j) = -alphadata(i,j);
                end
            end
        end
    end
    cmax = max(max(Z));
    cmin = min(min(Z));
    cc = max([abs(cmin) cmax])
    alphadata = 0.85*alphadata/cc;
    
    surface(X,Y,Z,'FaceAlpha',0.55)
    shading interp
    caxis([-cc cc])
    colorbar
    title(des)
end
figurename = ['Figure_Deform_',deform_name,'.png'];
print('-dpng', figurename);



