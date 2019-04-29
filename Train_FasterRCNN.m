close all;clear;clc

testData = readtable('window400_test_MATLAB.csv','Delimiter',',');
trainData = readtable('window400_train_MATLAB.csv','Delimiter',',');
%% 


for i=1:length(testData{:,1})
    testData{i,2} = {str2double(reshape(strsplit(cell2mat(testData{i,2})),4,[])')};
end

for j=1:length(trainData{:,1})
    trainData{j,2} = {str2double(reshape(strsplit(cell2mat(trainData{j,2})),4,[])')};
end

%% 

%%%%%%%%%%%%%Display One Image%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the fullpath to the local vehicle data folder.
% vehicleDataset.imageFilename = fullfile(pwd, vehicleDataset.imageFilename);
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

model_name = 'window_detector_fasterRCNN_0412';
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
%% 

%%%%%%%%%%%%%Evaluate on the test set%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if doTrainingAndEval
    % Create a table to hold the bounding boxes, scores, and labels output by
    % the detector.
    numImages = height(testData);
    results = table('Size',[numImages 3],...
        'VariableTypes',{'cell','cell','cell'},...
        'VariableNames',{'Boxes','Scores','Labels'});
    
    % Run detector on each image in the test set and collect results.
    for i = 1:numImages
        
        % Read the image.
        I = imread(testData.wd{i});
        
        % Run the detector.
        [bboxes, scores, labels] = detect(detector, I);
        
        % Collect the results.
        % Collect the results.
        results.Boxes{i} = bboxes;
        results.Scores{i} = scores;
        results.Labels{i} = labels;
    end
end

% Extract expected bounding box locations from test data.
expectedResults = testData(:, 2:end);

% Evaluate the object detector using Average Precision metric.
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);

%%%%%%%%%%%%%Plot the precision/recall curve%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(recall,precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f', ap))

%%%%%%%%%%%%%%%%%%Display all testing images%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
h = height(testData);
for j = 1:h
    J = imread(testData.wd{j});
    J = insertObjectAnnotation(J,'rectangle',results.Boxes{j},results.Scores{j});
    imwrite(J,strcat(pwd,'/test_0416/',num2str(j)),'png');
end
%%%%%%%%%%%%%%%%-----------End--------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
