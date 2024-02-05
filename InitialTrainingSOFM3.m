function Model = InitialTrainingSOFM3(ModelInput, Samples, NdxFrameIni)

Parameters = ModelInput.SOFM;

[Dimension,NumSamples]=size(Samples);

Parameters.NumSteps = NumSamples * 10; 

% Inicializacion
%fprintf('Initializing SOFM')
Model.NumColsMap=Parameters.NumColsMap;
Model.NumRowsMap=Parameters.NumRowsMap;
Model.Dimension=Dimension;
Model.Prototypes=zeros(Dimension,Model.NumRowsMap,Model.NumColsMap);
Model.MaxRadius = Parameters.MaxRadius;
Model.ConvergenceLearningRate = Parameters.ConvergenceLearningRate;
Model.InitialLearningRate = Parameters.InitialLearningRate;
Model.ConvergenceRadius = Parameters.ConvergenceRadius;
Model.NumSteps = NdxFrameIni + 100;
Model.Threshold = Parameters.Threshold;
Model.LogDistance = Parameters.LogDistance;
Model.MaxLogDistance = Parameters.MaxLogDistance;
Model.FactorPercentile = Parameters.FactorPercentile;

% Initialize along the two first principal directions
Options.disp=0;
Mu=mean(Samples,2);
Desv = std(Samples,0,2);
if NumSamples>Dimension
    C=cov(Samples');
    if Dimension>3
        Model.GlobalMu=Mu;
        Model.GlobalDesv = Desv;
        [Uq Lambdaq]=eigs(C,3,'LM',Options);
        Model.UqT=Uq';
    end
    [Uq Lambdaq]=eigs(C,2,'LM',Options);    
else
    % We use the eigenface trick here
    SamplesZeroMean=Samples-repmat(Mu,1,NumSamples); 
    L=SamplesZeroMean'*SamplesZeroMean;
    [Lvectors Lvalues]=eigs(L,3,'LM',Options);
    Uq=normc(SamplesZeroMean*Lvectors);
    Model.UqT=Uq';
    Model.GlobalMu=Mu;
    Lambdaq=Lvalues/(NumSamples-1);  
    % Next we only need the two first principal directions
    Uq=Uq(:,1:2);
    Lambdaq=Lambdaq(1:2,1:2);
end
UqLambdaq=Uq*sqrt(3*Lambdaq);
A=zeros(2,1);


tam = [ModelInput.FrameSize(1) ModelInput.FrameSize(2)];
ptox = (tam(1) / Model.NumRowsMap)/2:(tam(1) / Model.NumRowsMap):tam(1);
ptoy = (tam(2) / Model.NumColsMap)/2:(tam(2) / Model.NumColsMap):tam(2);
%ptoy = ptoy(end:-1:1);
ptox = ptox(end:-1:1);

for NdxRow=1:Model.NumRowsMap
    A(1)=-0.5+NdxRow/Model.NumRowsMap;
    for NdxCol=1:Model.NumColsMap
        A(2)=-0.5+NdxCol/Model.NumColsMap;
        %temp = (UqLambdaq*A);
        % Modificacion para situar las neuronas
        Model.Prototypes(1,NdxRow,NdxCol)=ptox(NdxRow);
        Model.Prototypes(2,NdxRow,NdxCol)=ptoy(NdxCol);
        
        % Se aprende solo el area y dimensiones
        %Model.Prototypes(3:5,NdxRow,NdxCol)=Mu(3:5)+temp(3:5);  
        temp = Mu+UqLambdaq*A; 
        %Model.Prototypes([1 2 6],NdxRow,NdxCol)=temp([1 2 6]);
        Model.Prototypes([6],NdxRow,NdxCol)=temp([6]);
        Model.Prototypes(3:5,NdxRow,NdxCol)=(temp(3:5) - Model.GlobalMu(3:5)) ./ Model.GlobalDesv(3:5);
        %fprintf('.')
    end
end

% Inicializo el vector de distancias de cada neurona (conexiones
% horizontales)
for NdxRow=1:Model.NumRowsMap
    for NdxCol=1:(Model.NumColsMap-1)
        Proto1 = Model.Prototypes(3:5,NdxRow,NdxCol);
        Proto2 = Model.Prototypes(3:5,NdxRow,NdxCol+1);
        SquaredDistance=sum((Proto1 - Proto2).^2,1);
        Model = addEntryLogDistance(Model,NdxRow,NdxCol,SquaredDistance);
        Model = addEntryLogDistance(Model,NdxRow,NdxCol+1,SquaredDistance);
    end
end

% Inicializo el vector de distancias de cada neurona (conexiones
% verticales)
for NdxRow=1:(Model.NumRowsMap-1)
    for NdxCol=1:Model.NumColsMap
        Proto1 = Model.Prototypes(3:5,NdxRow,NdxCol);
        Proto2 = Model.Prototypes(3:5,NdxRow+1,NdxCol);
        SquaredDistance=sum((Proto1 - Proto2).^2,1);
        Model = addEntryLogDistance(Model,NdxRow,NdxCol,SquaredDistance);
        Model = addEntryLogDistance(Model,NdxRow+1,NdxCol,SquaredDistance);
    end
end

