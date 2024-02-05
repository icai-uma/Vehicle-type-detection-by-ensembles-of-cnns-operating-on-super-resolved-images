function model = createSOFMModel

model.NumRowsMap=4;
model.NumColsMap=4;
model.InitialLearningRate=0.2;
model.MaxRadius=(model.NumRowsMap+model.NumColsMap)/4;
model.ConvergenceLearningRate=0.01;
model.ConvergenceRadius=0.5;
model.Threshold=3;
model.LogDistance = cell(model.NumRowsMap, model.NumColsMap);
model.MaxLogDistance = 50;
model.FactorPercentile = 2;