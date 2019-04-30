close all;clear;clc

trainData = readtable('trainData.csv','Delimiter',',');
for j=1:length(trainData{:,1})
    trainData{j,2} = {str2double(reshape(strsplit(cell2mat(trainData{j,2})),4,[])')};
end

%% 
%%%%%%%%%%%%%Display One Image%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Read one of the images.
I = imread(trainData.wd{428});
% Insert the ROI labels.
I = insertShape(I, 'Rectangle',trainData.bbox{428});
% Resize and display image.
I = imresize(I,2);
figure
imshow(I)

%%%%%%%%%%%%%Set Training Options%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options for step 1.
options = trainingOptions('sgdm', ...
    'MaxEpochs', 5, ...
    'MiniBatchSize', 1, ... %original = 1
    'InitialLearnRate', 1e-3, ...
    'ExecutionEnvironment', 'gpu',...
    'CheckpointPath', tempdir);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%Do Training%%%%%%%%%%%%%%%%%%%%%%%%%
doTrainingAndEval = true;

model_name = ''; %edit model name for saving purpose
if doTrainingAndEval
    [detector, info] = trainFasterRCNNObjectDetector(trainData, 'resnet50', options);
end
save (model_name,'-v7.3');
%% 
%%%%%%%%%%%%%Test on a single image%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read a test image.
I = imread(testData.wd{1});

% Run the detector.
[bboxes,scores] = detect(detector,I);

% Annotate detections in the image.
I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)
