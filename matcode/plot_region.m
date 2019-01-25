%plot sub-level grid region (a box) in its parent grid region
%parent bathymetry must be first plotted via plot_bath()

function plot_region(id)

if id < 10
    str_id = ['0',num2str(id)];
end
if id >= 10 & id<100
    str_id = num2str(id);
end
% str_id
% layer = load(['layer',str_id,'.dat']);
layer_x = load(['layer',str_id,'_x.dat']);
layer_y = load(['layer',str_id,'_y.dat']);
% [x,y] = meshgrid(layer_x,layer_y);

nx = length(layer_x);
ny = length(layer_y);

% depth = reshape(layer,nx,ny);

hold on
line([layer_x(1) layer_x(1)],[layer_y(1) layer_y(ny)],'Color','w','LineWidth',1)
line([layer_x(nx) layer_x(nx)],[layer_y(1) layer_y(ny)],'Color','w','LineWidth',1)
line([layer_x(1) layer_x(nx)],[layer_y(1) layer_y(1)],'Color','w','LineWidth',1)
line([layer_x(1) layer_x(nx)],[layer_y(ny) layer_y(ny)],'Color','w','LineWidth',1)

x_pos = 0.90*(layer_x(nx)-layer_x(1))+layer_x(1);
y_pos = 0.90*(layer_y(ny)-layer_y(1))+layer_y(1);
% text(x_pos,y_pos,str_id,'FontSize',12,'FontWeight','bold','Color','r')
figurename = ['Figure_NestedGridSetup']
print('-dpng', figurename);
