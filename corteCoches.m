function [propFrontera,IOut, handle_out] = corteCoches(I,model)

%close all;
CORTE = 0.2;
NumComponentes=2;
MaxIteraciones=50;

IOut = zeros(size(I)); 

handle_out = [];
if model.debug
    handle_out = figure;
    imshow((I > CORTE).*I,'InitialMagnification','fit');
    hold on;
end

[fil, col, val] = find(I > CORTE);
Muestras = [fil col]';
PesosMuestras = val';

[Modelo,NumIteraciones]=Training_L2MoG(Muestras,PesosMuestras,NumComponentes,MaxIteraciones);

a = (Modelo.Responsabilidades(1,:) > 0.35).*(Modelo.Responsabilidades(1,:) < 0.65);
muestras_frontera = Modelo.Muestras(:, find(a));

[Maximos Modelo.Asignaciones]=max(Modelo.Responsabilidades);
idxs = sub2ind(size(I),Modelo.Muestras(1,:),Modelo.Muestras(2,:));
IOut(idxs) = Modelo.Asignaciones;

if model.debug
    [Handle]=DibujarModeloL2VQ(Modelo);
    %CurrAxis=axis;
    hold on
    % [Handle]=PlotDecisionBoundaryMoG(Modelo);
    % axis(CurrAxis);
end

[fil, col, val] = find(I);
Muestras_test = [fil col]';
PesosMuestras_test = val';

[Modelo]=Testing_L2MoG(Modelo,Muestras_test);
a = (Modelo.Responsabilidades(1,:) > 0.35).*(Modelo.Responsabilidades(1,:) < 0.65);
muestras_frontera_tot = Modelo.Muestras(:, find(a));

idxs_frontera = sub2ind(size(I),muestras_frontera_tot(1,:),muestras_frontera_tot(2,:));
IOut(idxs_frontera) = 0;

if model.debug
    plot(muestras_frontera_tot(2,:),muestras_frontera_tot(1,:),'*r');
    plot(muestras_frontera(2,:),muestras_frontera(1,:),'*b');
end

%close;
se = strel('disk',2);
ImageDE = imdilate(imerode(IOut > 0, se),se);
IOut = IOut.*ImageDE;

propFrontera = size(muestras_frontera,2) / size(muestras_frontera_tot,2);
a = 1;