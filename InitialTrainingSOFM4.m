function Model = InitialTrainingSOFM4(ModelInput, Samples, NdxFrameIni)

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
UqLambdaq=Uq*sqrt(Lambdaq);
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
        %Model.Prototypes(1,NdxRow,NdxCol)=ptox(NdxRow);
        %Model.Prototypes(2,NdxRow,NdxCol)=ptoy(NdxCol);
        
        % Se aprende solo el area y dimensiones
        %Model.Prototypes(3:5,NdxRow,NdxCol)=Mu(3:5)+temp(3:5);  
        A(2)=-0.5+NdxCol/Model.NumColsMap;
        Model.Prototypes(:,NdxRow,NdxCol)=Mu+UqLambdaq*A;  
        Model.Prototypes(3:5,NdxRow,NdxCol) = 1;
        %fprintf('.')
    end
end

