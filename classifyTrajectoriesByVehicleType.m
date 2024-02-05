function classifyTrajectoriesByVehicleType()

clear all
close all
warning off
rng('default');

NumMinAssociations = 30;
vehicleTypes = {'moto', 'car', 'van', 'truck'};

params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoriesWithRepresentativeDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/trajectoriesWithRepresentative/');

infoFiles = dir(params.TrajectoriesWithRepresentativeDirectory);
cont = 1;
contLabeledData = 1;
contNoLabeledData = 1;

% Load data
for i=1:length(infoFiles)
    if (infoFiles(i).isdir == 0)
        
        filename = infoFiles(i).name;
        [pathstr, name, ext] = fileparts(filename);
        % Take only the .mat files
        if (strcmpi(ext,'.mat') == 1)  %&& (strcmpi(name,'kModel_293') == 1)
            path_mat = strcat(params.TrajectoriesWithRepresentativeDirectory,filename);
            load(path_mat);
            disp(strcat(name, ' file is computing...'));
            % For each trajectory
            for j=1:size(kModel.SavedTrayectories,2)
                if kModel.SavedTrayectories(j).numVecesMatching > NumMinAssociations  % trajectories with more than NumMinAssociations
                    % Take the stats of the trajectory
                    trajectoryData = [double(kModel.SavedTrayectories(j).Representative.Area); ...
                                      double(kModel.SavedTrayectories(j).Representative.Perimeter); ...
                                      double(kModel.SavedTrayectories(j).Representative.BoundingBox(3)); ... %ancho y alto
                                      double(kModel.SavedTrayectories(j).Representative.BoundingBox(4));];
%                     trajectoryData = [double(kModel.SavedTrayectories(j).Representative.Area); ...
%                                       double(kModel.SavedTrayectories(j).Representative.Perimeter); ...
%                                       double(kModel.SavedTrayectories(j).Representative.BoundingBox(3)); ... %ancho y alto
%                                       double(kModel.SavedTrayectories(j).Representative.BoundingBox(4)); ...
%                                       double(kModel.SavedTrayectories(j).Representative.Solidity); ...
%                                       double(kModel.SavedTrayectories(j).Representative.medianColour(1)); ...
%                                       double(kModel.SavedTrayectories(j).Representative.medianColour(2)); ...
%                                       double(kModel.SavedTrayectories(j).Representative.medianColour(3));];
                    cont = cont + 1;
                    if ~isempty(kModel.SavedTrayectories(j).Representative.DefinedVehicleType)
                        %trayectoria comprobada manualmente
                        if (strcmpi(kModel.SavedTrayectories(j).Representative.DefinedVehicleType,'moto') == 1)
                            idVehicleType = 1;
                        elseif (strcmpi(kModel.SavedTrayectories(j).Representative.DefinedVehicleType,'car') == 1)
                            idVehicleType = 2;
                        elseif (strcmpi(kModel.SavedTrayectories(j).Representative.DefinedVehicleType,'van') == 1)
                            idVehicleType = 3;
                        elseif (strcmpi(kModel.SavedTrayectories(j).Representative.DefinedVehicleType,'truck') == 1)
                            idVehicleType = 4;
                        else
                            disp('error');
                        end
                        labeledData(:,contLabeledData) = trajectoryData;
                        labeledType(contLabeledData) = idVehicleType;
                        labeledDataID(contLabeledData) = kModel.SavedTrayectories(j).ID;
                        contLabeledData = contLabeledData + 1;
                        %disp(sprintf('Trajectory %s has the defined vehicle type %s ...',num2str(j),kModel.SavedTrayectories(j).Representative.DefinedVehicleType));
                    else
                        noLabeledData(:,contNoLabeledData) = trajectoryData;
                        contNoLabeledData = contNoLabeledData + 1;
                    end
                end
            end
            disp(strcat(name, ' file finished...'));
        end
    end
end
data = [labeledDataID ; labeledType; labeledData];
%data(:,find(data(2,:)==1)) %mostrar todos los datos de los elementos con vehicleType=1
disp('Calculating the model...');

numVehicleTypes = numel(vehicleTypes);

%%% K-MEANS - INI
%data = labeledData;
%[trajectoriesClasses,centroids] = kmeans(data,numVehicleTypes);
%%% K-MEANS - FIN


%%% GNG - INI
% Preparar muestras y etiquetas de entrenamiento y de test
TodasMuestras=[];
TodasEtiqs=[];
ProbClase=[];

TodasMuestras = labeledData;
TodasEtiqs = labeledType;
% for NdxClase=1:numVehicleTypes
%     ProbClase(NdxClase)=size(TodasEtiqs(find(TodasEtiqs==NdxClase)),2);
% end
% ProbClase=ProbClase/sum(ProbClase);
% 
% % Create configurations with 90% training data and 10% test data
% Indices=ceil(10*rand(size(TodasMuestras,2),1));
% for NdxRepeticion=1:10
%     Muestras{NdxRepeticion}=TodasMuestras(:,find(Indices~=NdxRepeticion));
%     Etiqs{NdxRepeticion}=TodasEtiqs(find(Indices~=NdxRepeticion));
%     MuestrasTest{NdxRepeticion}=TodasMuestras(:,find(Indices==NdxRepeticion));
%     EtiqsTest{NdxRepeticion}=TodasEtiqs(find(Indices==NdxRepeticion));
% end

fraction = 0.9;
classes = [1 2 3 4];
nClasses = 4;

for NdxRepeticion=1:10
    MuestrasTest{NdxRepeticion}=[];
    Muestras{NdxRepeticion}=[];
    Etiqs{NdxRepeticion}=[];
    EtiqsTest{NdxRepeticion} = [];
    for i = 1:nClasses
        idx = find(TodasEtiqs == classes(i));
        classItems = TodasMuestras(:,idx);
        numItemsClass = size(idx,2);
        numTestItemsClass = ceil((1-fraction)*numItemsClass);
        
        idxRandom = randsample(numItemsClass,numItemsClass);
        MuestrasTest{NdxRepeticion} = [MuestrasTest{NdxRepeticion} classItems(:,idxRandom(1:numTestItemsClass))];
        Muestras{NdxRepeticion} = [Muestras{NdxRepeticion} classItems(:,idxRandom(numTestItemsClass+1:numItemsClass))];
        etiqsClass(1:numItemsClass)=i;
        EtiqsTest{NdxRepeticion} = [EtiqsTest{NdxRepeticion} etiqsClass(1:numTestItemsClass)];
        Etiqs{NdxRepeticion} = [Etiqs{NdxRepeticion} etiqsClass(numTestItemsClass+1:numItemsClass)];
    end
end




% Preparar campo del resultado
NombreBase = 'Trajectories';
Resultados=[];
Resultados=setfield(Resultados,NombreBase,[]);

% The following values of the parameters are those considered in the
% original GNG paper by Fritzke (1995)
Lambda=1000;
NumSteps=20000;
EpsilonB=0.2;
EpsilonN=0.006;
Alpha=0.5;
AMax=50;
D=0.995;

% Parameters to be used
EpsilonN=0.0005;
NumEtapas=100000;

NumFilasMapa=2;
NumColsMapa=2;
MaxUnits=NumFilasMapa*NumColsMapa;

Evaluaciones=[];
disp('Training the model...');
for NdxRepeticion=1:10
    disp(sprintf('Repetition %d...',NdxRepeticion));
    
    MuestrasMinValue = min(TodasMuestras,[],2);
    MuestrasMaxValue = max(TodasMuestras,[],2);
    contMuestraTest=1;
    contMuestraNoLabeled=1;
    
    for NdxClase=1:numVehicleTypes
        disp(sprintf('Class %d...',NdxClase));
        IndicesMuestras=find(Etiqs{NdxRepeticion}==NdxClase);
        MuestrasTrain=Muestras{NdxRepeticion}(:,IndicesMuestras);
        
        %disp(sprintf('Number of training items from class %d: %d',NdxClase, size(MuestrasTrain,2)));
        
        Modelo=TrainGNG(MuestrasTrain,MaxUnits,Lambda,EpsilonB,EpsilonN,Alpha,AMax,D,NumEtapas);
        
        Modelo.NumFilasMapa=NumFilasMapa;
        Modelo.NumColsMapa=NumColsMapa;
        Modelos{NdxRepeticion,NdxClase} = Modelo;        
        
        MuestrasTestRep=MuestrasTest{NdxRepeticion}; 
         
        % calculate distances between test elements and neurons
        for NdxMuestra=1:size(MuestrasTestRep,2)
            for NdxNeuro=1:MaxUnits %las distancias las normalizamos
                distancesItemNeurons(NdxNeuro,:) = abs((MuestrasTestRep(:,NdxMuestra)-MuestrasMinValue)./(MuestrasMaxValue-MuestrasMinValue) -...
                                                        ((Modelo.Means(:,NdxNeuro))-MuestrasMinValue)./(MuestrasMaxValue-MuestrasMinValue));
            end
            distancesTestItemsNeurons{NdxMuestra,NdxClase}=distancesItemNeurons;
            %save the min distance
            minDistanceTestItemClass(NdxMuestra,NdxClase) = min(min(distancesTestItemsNeurons{NdxMuestra,NdxClase}));
        end
        
        
        % calculate distances between no labeled elements and neurons
        for NdxMuestra=1:size(noLabeledData,2)
            for NdxNeuro=1:MaxUnits %las distancias las normalizamos
                distancesItemNeurons(NdxNeuro,:) = abs((noLabeledData(:,NdxMuestra)-MuestrasMinValue)./(MuestrasMaxValue-MuestrasMinValue) -...
                                                        ((Modelo.Means(:,NdxNeuro))-MuestrasMinValue)./(MuestrasMaxValue-MuestrasMinValue));
            end
            distancesNoLabeledItemsNeurons{NdxMuestra,NdxClase}=distancesItemNeurons;
            %save the min distance
            minDistanceNoLabeledItemClass(NdxMuestra,NdxClase) = min(min(distancesNoLabeledItemsNeurons{NdxMuestra,NdxClase}));
        end
        
    end
    
    
    % tag the test elements
    for NdxMuestra=1:size(MuestrasTest{NdxRepeticion},2)
        minDistance = min(minDistanceTestItemClass(NdxMuestra,:));
        MisEtiqsTestData{NdxRepeticion}(NdxMuestra) = find(minDistanceTestItemClass(NdxMuestra,:)==minDistance,1);
    end
        
    % tag the no labeled elements
    for NdxMuestra=1:size(noLabeledData,2)
        minDistance = min(minDistanceNoLabeledItemClass(NdxMuestra,:));
        MisEtiqsNoLabeledData{NdxRepeticion}(NdxMuestra) = find(minDistanceNoLabeledItemClass(NdxMuestra,:)==minDistance,1);
    end
    
    %evaluate the repetition NdxRepeticion of the model
    Evaluaciones{NdxRepeticion}=EvaluarClasificador(EtiqsTest{NdxRepeticion},MisEtiqsTestData{NdxRepeticion});
end

%evaluate the model
MiResultado=ValidacionCruzadaClasificador(Evaluaciones);
%%% GNG - FIN

%plot the model
NdxRepeticion = 9;




NdxMeasureX = 3;
NdxMeasureY = 4;

MyColorMap = distinguishable_colors(numVehicleTypes);

%plot the neural network and the labeled data
figure;
hold on
for NdxClase=1:numVehicleTypes
    Modelo = Modelos{NdxRepeticion,NdxClase};
    %plot the neurons of the neural network
    plot(Modelo.Means(NdxMeasureX,:),Modelo.Means(NdxMeasureY,:),'or','Color',MyColorMap(NdxClase,:))
    
    %plot the neurons connections
    for NdxUnit=1:Modelo.MaxUnits
        if isfinite(Modelo.Means(NdxMeasureX,NdxUnit))
            NdxNeighbors=find(Modelo.Connections(NdxUnit,:));
            for NdxMyNeigh=1:numel(NdxNeighbors)
                line([Modelo.Means(NdxMeasureX,NdxUnit) Modelo.Means(NdxMeasureX,NdxNeighbors(NdxMyNeigh))],...
                    [Modelo.Means(NdxMeasureY,NdxUnit) Modelo.Means(NdxMeasureY,NdxNeighbors(NdxMyNeigh))],...
                    'Color',MyColorMap(NdxClase,:));
                hold on
            end
        end
    end
    
    %plot the labeled data
    plot(TodasMuestras(NdxMeasureX,find(TodasEtiqs==NdxClase)),TodasMuestras(NdxMeasureY,find(TodasEtiqs==NdxClase)),'.','MarkerSize',12,'Color',MyColorMap(NdxClase,:));
    hold on
end
xlabel('Width','fontsize',16) 
ylabel('Height','fontsize',16) 
%legend('1','2','3','4','Centroids','Location','NW')
title ('Model','fontsize',16)
hold off

PdfFileName=sprintf('model_4neurons_4charact_width_height.pdf');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
set(gca,'fontsize',10);
saveas(gcf,PdfFileName,'pdf');


%plot the no labeled data
figure;
hold on
for NdxClase=1:numVehicleTypes
    Modelo = Modelos{NdxRepeticion,NdxClase};
    hold on
    %plot the no labeled data
    plot(noLabeledData(NdxMeasureX,find(MisEtiqsNoLabeledData{NdxRepeticion}==NdxClase)),noLabeledData(NdxMeasureY,find(MisEtiqsNoLabeledData{NdxRepeticion}==NdxClase)),'.','MarkerSize',12,'Color',MyColorMap(NdxClase,:));
end
xlabel('Width','fontsize',16) 
ylabel('Height','fontsize',16) 
%legend('1','2','3','4','Centroids','Location','NW')
title ('Classification','fontsize',16)
hold off

PdfFileName=sprintf('results_4neurons_4charact_width_height.pdf');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
set(gca,'fontsize',10);
saveas(gcf,PdfFileName,'pdf');





NdxMeasureX = 1;
NdxMeasureY = 2;

MyColorMap = distinguishable_colors(numVehicleTypes);
figure;
hold on
for NdxClase=1:numVehicleTypes
    Modelo = Modelos{NdxRepeticion,NdxClase};
    %plot the neurons of the neural network
    plot(Modelo.Means(NdxMeasureX,:),Modelo.Means(NdxMeasureY,:),'or','Color',MyColorMap(NdxClase,:))
    
    %plot the neurons connections
    for NdxUnit=1:Modelo.MaxUnits
        if isfinite(Modelo.Means(NdxMeasureX,NdxUnit))
            NdxNeighbors=find(Modelo.Connections(NdxUnit,:));
            for NdxMyNeigh=1:numel(NdxNeighbors)
                line([Modelo.Means(NdxMeasureX,NdxUnit) Modelo.Means(NdxMeasureX,NdxNeighbors(NdxMyNeigh))],...
                    [Modelo.Means(NdxMeasureY,NdxUnit) Modelo.Means(NdxMeasureY,NdxNeighbors(NdxMyNeigh))],...
                    'Color',MyColorMap(NdxClase,:));
                hold on
            end
        end
    end
    
    %plot the labeled data
    plot(TodasMuestras(NdxMeasureX,find(TodasEtiqs==NdxClase)),TodasMuestras(NdxMeasureY,find(TodasEtiqs==NdxClase)),'.','MarkerSize',12,'Color',MyColorMap(NdxClase,:));
    hold on

end
xlabel('Area','fontsize',16) 
ylabel('Perimeter','fontsize',16) 
%legend('1','2','3','4','Centroids','Location','NW')
title ('Model','fontsize',16)
hold off

PdfFileName=sprintf('model_4neurons_4charact_area_perimeter.pdf');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
set(gca,'fontsize',10);
saveas(gcf,PdfFileName,'pdf');

figure;
hold on
for NdxClase=1:numVehicleTypes
    Modelo = Modelos{NdxRepeticion,NdxClase};
    hold on
    %plot the no labeled data
    plot(noLabeledData(NdxMeasureX,find(MisEtiqsNoLabeledData{NdxRepeticion}==NdxClase)),noLabeledData(NdxMeasureY,find(MisEtiqsNoLabeledData{NdxRepeticion}==NdxClase)),'.','MarkerSize',12,'Color',MyColorMap(NdxClase,:));
end
xlabel('Area','fontsize',16) 
ylabel('Perimeter','fontsize',16) 
%legend('1','2','3','4','Centroids','Location','NW')
title ('Classification','fontsize',16)
hold off

PdfFileName=sprintf('results_4neurons_4charact_area_perimeter.pdf');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
set(gca,'fontsize',10);
saveas(gcf,PdfFileName,'pdf');



% %% GENERATE THE CLASS LEGEND
sortedListVideos = [1 2 3 4];
ListDatasets = {'moto','car','van','truck'};
NumVideos=numel(ListDatasets);
figure
Handle=zeros(NumVideos,1);
for NdxMethod=sortedListVideos
    Handle(NdxMethod)=plot(2:6,2:6,...
        '.','Color',MyColorMap(NdxMethod,:),'LineWidth',1.5,'MarkerSize',12);
        %'o','Color',MyColorMap(NdxMethod,:),'LineWidth',1.5,'MarkerEdgeColor','none','MarkerFaceColor',MyColorMap(NdxMethod,:));
        
    
    hold on
end
legHdl = gridLegend(Handle(sortedListVideos),5,ListDatasets(sortedListVideos));

PdfFileName='classLegend.pdf';
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[11 0.6]); %sustituir 10 por 20
set(gcf,'PaperPosition',[0 0 11 13.5]);
set(gca,'fontsize',11);
set(gca, 'visible', 'off');

set(gca,'fontsize',11)
saveas(gcf,PdfFileName,'pdf');



% %% GENERATE THE MODEL LEGEND
sortedListVideos = [1 2 3];
ListDatasets = {'vehicle','neuron','connection'};
ListSymbol={'.','o', '-'};
ListMarkerSize={12,6,10};

NumVideos=numel(ListDatasets);
figure
Handle=zeros(NumVideos,1);
for NdxMethod=sortedListVideos
    Handle(NdxMethod)=plot(2:6,2:6,...
        ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'LineWidth',1,'MarkerSize',ListMarkerSize{NdxMethod});
    hold on
end
legHdl = gridLegend(Handle(sortedListVideos),5,ListDatasets(sortedListVideos));

PdfFileName='modelLegend.pdf';
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[11 0.6]); %sustituir 10 por 20
set(gcf,'PaperPosition',[0 0 11 13.5]);
set(gca,'fontsize',11);
set(gca, 'visible', 'off');

set(gca,'fontsize',11)
saveas(gcf,PdfFileName,'pdf');


%para cada .mat se guardan los resultados predecidos
%kModel.SavedTrayectories(ndxTrajectoryId).Representative.PredictedVehicleType
%save(path_mat,'kModel');




