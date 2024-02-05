function [Winners,Errors]=CompetitionSOFM(Model,Samples)

NumSamples=size(Samples,2);
NumNeuro=Model.NumRowsMap*Model.NumColsMap;
Prototypes=Model.Prototypes(:,:);
Winners=zeros(NumSamples,1);
Errors=zeros(NumSamples,1);

for NdxSample=1:NumSamples   
    SquaredDistances=sum((repmat(Samples(:,NdxSample),1,NumNeuro)-Prototypes).^2,1);
    [Minimum NdxWinner]=min(SquaredDistances);
    Winners(NdxSample)=NdxWinner;
    Errors(NdxSample)=Minimum;

    %if mod(NdxSample,10000)==0
    %    fprintf('%d samples analyzed\n',NdxSample);
    %end
end

