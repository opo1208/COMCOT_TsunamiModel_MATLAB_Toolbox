% This script is used to convert the output file (.dat, .dep) of COMCOT into XYZ file (3 colomns)
% *.dep file: this is water depth data file formatted for COMCOT (v1.6 or earlier) 
% *.xyz file: contains 3 columns representing gridded data
% coordinate data files, layer##_x.dat and layer##_y.dat should be created
% first before using this script, where ## stands for layer id.
% Output file: fname_out

function comcot2xyz()

cmax = 5; %change to adjust color scale

data_file = input('Input COMCOT data file name:');
x_file = input('Input X Coordinate file name (e.g.,layer##_x.dat):');
y_file = input('Input Y Coordinate file name (e.g.,layer##_y.dat):');
fname_out = input('Input output data file name:');
% fname = 'etamax_layer01.dat'
%load bathymetry data

disp('Loading Data into Memory...')
% layer = load(data_file);
layer_x = load(x_file);
layer_y = load(y_file);
[x,y] = meshgrid(layer_x,layer_y);

nx = length(layer_x);
ny = length(layer_y);

fid = fopen(data_file);
a = fscanf(fid,'%g',inf); % write all data into a column of matrix a.
fclose(fid);

layer = reshape(a,nx,ny);

% save data in XYZ-format
disp('Writing data into a XYZ-format file ...')
NN = nx*ny;

bathymetry = zeros(NN,3);

iflip = 0;  %iflip = 0: write from south to north; 1 - write data from north to south

if iflip == 1
   data = reshape(a,nx,ny);
   clear a
   size(data)
   dataflip = flipud(data);
   size(dataflip)
   clear data
   
   layer_y = flipud(layer_y);
   for j = 1:ny
       ks = (j-1)*nx+1;
       ke = j*nx;
       bathymetry(ks:ke,1) = layer_x;
       bathymetry(ks:ke,2) = layer_y(j);
       bathymetry(ks:ke,3) = dataflip(1:nx,j);
   end
end

if iflip == 0
%    bathymetry(:,3) = a;
    for j = 1:ny
        ks = (j-1)*nx+1;
        ke = j*nx;
        bathymetry(ks:ke,1) = layer_x;
        bathymetry(ks:ke,2) = layer_y(j);
        bathymetry(ks:ke,3) = layer(:,j);
    end
end
clear flowdepth

fid = fopen(fname_out,'.xyz'],'w+');
%write dimension of slide data slide(nx,ny,nt)
%write x coordinates
for i=1:NN
    fprintf(fid,'%17.6f %17.6f %8.3f\n',bathymetry(i,1),bathymetry(i,2),bathymetry(i,3));
end
fclose(fid)







