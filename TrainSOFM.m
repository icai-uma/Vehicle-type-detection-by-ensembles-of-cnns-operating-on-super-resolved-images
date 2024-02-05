function [Model]=TrainSOFM(Samples,Parameters)
% Train a Kohonen's SOFM model
[Dimension,NumSamples]=size(Samples);

% Inicializacion
%fprintf('Initializing SOFM')
NumNeuro=Parameters.NumRowsMap*Parameters.NumColsMap;
Model.NumColsMap=Parameters.NumColsMap;
Model.NumRowsMap=Parameters.NumRowsMap;
Model.Dimension=Dimension;
Model.Prototypes=zeros(Dimension,Model.NumRowsMap,Model.NumColsMap);

% Initialize along the two first principal directions
Options.disp=0;
Mu=mean(Samples,2);
if NumSamples>Dimension
    C=cov(Samples');
    if Dimension>3
        Model.GlobalMu=Mu;
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
for NdxRow=1:Model.NumRowsMap
    A(1)=-0.5+NdxRow/Model.NumRowsMap;
    for NdxCol=1:Model.NumColsMap
        A(2)=-0.5+NdxCol/Model.NumColsMap;
        Model.Prototypes(:,NdxRow,NdxCol)=Mu+UqLambdaq*A;  
        %fprintf('.')
    end
end

[AllXCoords AllYCoords]=ind2sub([Model.NumRowsMap Model.NumColsMap],1:NumNeuro);
AllCoords(1,:)=AllXCoords;
AllCoords(2,:)=AllYCoords;
for NdxNeuro=1:NumNeuro    
    DistTopol{NdxNeuro}=sum((repmat(AllCoords(:,NdxNeuro),1,NumNeuro)-AllCoords).^2,1);
end

% Training
%fprintf('\nTraining SOFM\n')
%MaxRadius=(NumRowsMap+NumColsMap)/8;
Model.Intersections=0;
OldMeans=Model.Prototypes;
for NdxStep=1:Parameters.NumSteps
    MySample=Samples(:,ceil(NumSamples*rand(1)));
    if NdxStep<0.5*Parameters.NumSteps   
        % Ordering phase: linear decay
        LearningRate=Parameters.InitialLearningRate*(1-NdxStep/Parameters.NumSteps);
        MyRadius=Parameters.MaxRadius*(1-(NdxStep-1)/Parameters.NumSteps);
    else
        % Convergence phase: constant
        LearningRate=Parameters.ConvergenceLearningRate;
        MyRadius=Parameters.ConvergenceRadius;
    end
    
    SquaredDistances=sum((repmat(MySample,1,NumNeuro)-Model.Prototypes(:,:)).^2,1);
    [Minimum NdxWinner]=min(SquaredDistances);
    Coef=repmat(LearningRate*exp(-DistTopol{NdxWinner}/(MyRadius^2)),Dimension,1);

    % Update the neurons
    Model.Prototypes(:,:)=Coef.*repmat(MySample,1,NumNeuro)+...
        (1-Coef).*Model.Prototypes(:,:);
    %if mod(NdxStep,10000)==0
    %    fprintf('%d steps completed\n',NdxStep);
    %end
end

%fprintf('Training finished\n')

    
    
        
