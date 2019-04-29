%%%%%%%%%%%%%%%%%%%%%%%load pretrained detector%%%%%%%%%%%%%%%%%%%%

clear all;clc;
load window_detector_fasterRCNN_0424.mat;

%%%%%%%%%%%%%%%%%%%%load test data and detection%%%%%%%%%%%%%%%%%%%
testData = readtable('window_test_MATLAB.csv','Delimiter',',');
results = table('Size',[height(testData) 3],...
        'VariableTypes',{'cell','cell','cell'},...
        'VariableNames',{'Boxes','Scores','Labels'});
mkdir test_original_m0423(incv3);
equal{1,1} = ['0 0 1 1'];
for i = 1:height(testData)
    I = imread(testData.wd{i});
    if (isequal(testData.bbox{i},equal{1,1})==0)
    tic;
    [bboxes, scores, labels] = detect(detector, I,'Threshold',0.9);
    toc;
    results.Boxes{i} = bboxes;
    results.Scores{i} = scores;
    results.Labels{i} = labels;
    if (isempty(labels)==0)
        J = insertObjectAnnotation(I,'rectangle',results.Boxes{i},results.Scores{i});
        imwrite(J,strcat(pwd,'/test_original_m0423(incv3)/',num2str(i)),'png');
    end
    end
end
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%Evaluatoin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(testData{:,1})
    testData{i,2} = {str2double(reshape(strsplit(cell2mat(testData{i,2})),4,[])')};
end
expectedResults = testData(:, 2:end);
results2 = table('Size',[height(testData) 2],...
        'VariableTypes',{'cell','cell'},...
        'VariableNames',{'Boxes','Scores'});
results2.Boxes = results.Boxes;
results2.Scores = results.Scores;
[ap, recall, precision] = evaluateDetectionPrecision(results2, expectedResults);
figure
plot(recall,precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f', ap))
