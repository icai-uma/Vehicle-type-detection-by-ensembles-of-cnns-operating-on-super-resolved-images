function [Winners, Errors, Distances] = TestingSOFM(model, Samples, NdxFrame)

% Training
%fprintf('\nTraining SOFM\n')
%MaxRadius=(NumRowsMap+NumColsMap)/8;
NumNeuro=model.NumRowsMap*model.NumColsMap;
[Dimension,NumSamples]=size(Samples);
[AllXCoords AllYCoords]=ind2sub([model.NumRowsMap model.NumColsMap],1:NumNeuro);
AllCoords(1,:)=AllXCoords;
AllCoords(2,:)=AllYCoords;
for NdxNeuro=1:NumNeuro    
    DistTopol{NdxNeuro}=sum((repmat(AllCoords(:,NdxNeuro),1,NumNeuro)-AllCoords).^2,1);
end

Winners=zeros(NumSamples,1);
Distances=zeros(NumSamples,1);
Errors=zeros(NumSamples,1);

for i=1:NumSamples
    MySample=Samples(:,i);
    if NdxFrame<model.NumSteps   
        % Ordering phase: linear decay
        LearningRate=model.InitialLearningRate*(1-NdxFrame/model.NumSteps);
        MyRadius=model.MaxRadius*(1-(NdxFrame-1)/model.NumSteps);
    else
        % Convergence phase: constant
        LearningRate=model.ConvergenceLearningRate;
        MyRadius=model.ConvergenceRadius;
    end

    SquaredDistancesPosition=sum((repmat(MySample(1:2),1,NumNeuro)-model.Prototypes(1:2,:)).^2,1);
    
    [Minimum NdxWinner]=min(SquaredDistancesPosition);
    
    SquaredDistance=sum((MySample(3:5) - model.Prototypes(3:5,NdxWinner)).^2,1);
    
    Winners(i)=NdxWinner;
    Distances(i)=SquaredDistance;
    
    [f,c] = ind2sub([model.NumRowsMap model.NumColsMap], NdxWinner);
    
    
    %if SquaredDistance < model.Threshold
    if SquaredDistance < (model.FactorPercentile*prctile(model.LogDistance{f,c},95)) 
    
    else
        Errors(i) = 1;
    end
 end
%
    

    
        

