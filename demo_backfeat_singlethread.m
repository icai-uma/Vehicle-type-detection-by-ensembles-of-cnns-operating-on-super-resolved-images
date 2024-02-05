
clear all

SelectedFeatures{1}=[19 20 22];
SelectedFeatures{2}=[3 20 21 22];
SelectedFeatures{3}=[4 19 20 21];
SelectedFeatures{4}=[5 19 20 22];
SelectedFeatures{5}=[5 19 21 22];
SelectedFeatures{6}=[19 20 21 22];
SelectedFeatures{7}=[4 19 20 21 22];
SelectedFeatures{8}=[5 6 19 20 22];
SelectedFeatures{9}=[5 19 20 21 22];
SelectedFeatures{10}=[6 19 20 21 22];
SelectedFeatures{11}=[1 2 3];

epsilon=[0.0001 0.0005 0.001 0.005 0.01];

% Video to be processed

VideoFileSpec{1}='videos/baseline/highway/input/in%06d.jpg';
deltaFrame{1}=0;
numFrames{1}=1700;

% VideoFileSpec{2}='Videos/LevelCrossing/f%07d.bmp';
% deltaFrame{2}=0;
% numFrames{2}=500;
% 
% VideoFileSpec{3}='Videos/Video2/f%07d.bmp';
% deltaFrame{3}=0;
% numFrames{3}=749;

NdxVideo=1;

NdxFeatureSort=11;
NdxEpsilon=4;

AutomatedTestBMsinglethread(SelectedFeatures{NdxFeatureSort},VideoFileSpec{NdxVideo},deltaFrame{NdxVideo},numFrames{NdxVideo},epsilon(NdxEpsilon));


