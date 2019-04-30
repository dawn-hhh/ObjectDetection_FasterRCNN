# ObjectDetection_FasterRCNN
This repo contains codes for training MATLAB Faster-R-CNN models for object detection, four folders includes training and testing codes, data preperation codes and etc.

# Main
MATLAB scripts for model training(1) and testing(2) are inside this folder

# Data_Prepare
Ground truth(gt) data used in this model will be csv format, which can be generated via codes in python. 
1. The .ipynb file(3) inside this folder is for csv file and bbox generation. 
2. The two subfolders contains sample bbox image and sample training data; for training data, both original and ground truth image are needed, while ground truth images can be generated via MATLAB's 'Image Segmenter'(4).

# Sample_Test_Result 
This folder contains sample test images, in which objects are detected(in this case, windows) and prediction scores are presented.

# Estimate_Anchor
This folder contains MATLAB codes(5) for anchor box estimation using clustering and sample results. This method can be used when detection objects are of various sizes and shapes (eg. cracks), it gives a sense of what anchor box respect ratios fits objects in training set better.  

# For the codes in above folders, here are some brief guides
(1). Train_FasterRCNN.m

    a. input: trainingData csv file, format: column1--filename|column2--anchorbox cooridinates(x1,y1,w,h)
    b. customize training options and train model detector
    c. save trained model
    
(2). Test_FasterRCNN.m
    
    a. input: trained object detector & testdata csv file(with gt can better evaluate test results)
    b. run detector and save image results to folder
    c. generate mean average precision curve
    
(3). prepareDataPascalMulti.ipynb

    a. input: original training data directory and gt data directory
    b. output: bbox images in a folder and csv file (for MATLAB coordinates must be positive integer)
    
(4). Image Segmenter
 
    a. location: install inside MATLAB APPS
    b. output: B&W gt images(can be both workspace and outer) and table contains cooridinates(workspace)
    
(5). AnchorBoxesEstimationUsingKMeansClusteringExample.mlx

    a. input: training data csv file
     
