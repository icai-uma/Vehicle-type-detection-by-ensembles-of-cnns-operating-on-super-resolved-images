%clear all

Samples=rand(3,10000);
Parameters.NumSteps=100000;
Parameters.NumRowsMap=8;
Parameters.NumColsMap=8;
Parameters.InitialLearningRate=0.4;
Parameters.MaxRadius=(Parameters.NumRowsMap+Parameters.NumColsMap)/4;
Parameters.ConvergenceLearningRate=0.01;
Parameters.ConvergenceRadius=1;

% Original SOFM
tic
Model=TrainSOFM(Samples,Parameters);
toc
[Winners,Errors]=CompetitionSOFM(Model,Samples);
MSE=mean(Errors)
[Handle]=PlotSOM3D(Model,Samples(:,1:100:end))