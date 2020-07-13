clear
close all
clc
tic

filename = 'C:\Users\gxs160730\Documents\Ph.D\CNN-SE\CNN-VAD\Features\Training\LPS\MACHINERY\DUMMY\HINT_test_M_0.mat';

%Enter the path to your extracted features mat file
b = load(filename);
width = 5;

%%

trainData = cell2mat(b.trainData);
%testData  = cell2mat(b.testData);

fileNumbers = unique(trainData(:,259));

init = 0;
count=0;
for n = 1:numel(fileNumbers)
    
    index = trainData(:,259) == fileNumbers(n);
    melData = trainData(index, 1:129)';
    labels  = trainData(index, 130:258)';
    %class   = trainData(index, 43);
    
    beginIndex = 1:1:size(melData,2) - 10;
    endIndex = 11:1:size(melData,2);
    
    
    if init == 0
        
        nImagesPerFile  = numel(beginIndex);
        nImagesTotal    = nImagesPerFile * numel(fileNumbers);
        trainingData    = zeros(nImagesTotal,129,11);
        trainingLabels  = zeros(nImagesTotal,129);

        sectionStart   = 0;
        init           = 1;
        
    end
    %%  PAPER METHOD
%     for i = 1:numel(beginIndex)
%         
%         trainingData(sectionStart + i,:,:) = melData(:, beginIndex(i):endIndex(i));
%         
%         %         if(sum(labels(beginIndex(i):endIndex(i))) > width)
%         trainingLabels(sectionStart + i, :) = labels(:, (beginIndex(i)+ endIndex(i))/2 );
%         %         else
%         %             trainingLabels(sectionStart + i, :) = [1,0];
%         %         end
%         
%         count=count+1;
%         
%         if rem(count, 100000)==0
%             disp(count)
%         end
%         %trainingClass(sectionStart + i) = class(i);
%     end
    %% REAL-TIME METHOD 
    for i = 1:numel(beginIndex)

    trainingData(sectionStart + i,:,:) = melData(:, beginIndex(i):endIndex(i));

    %         if(sum(labels(beginIndex(i):endIndex(i))) > width)
    trainingLabels(sectionStart + i, :) = labels(:, endIndex(i) );
    %         else
    %             trainingLabels(sectionStart + i, :) = [1,0];
    %         end

%     count=count+1;
% 
%     if rem(count, 100000)==0
%         disp(count)
%     end
    %trainingClass(sectionStart + i) = class(i);
    end  
    
    sectionStart = sectionStart + i;


end
disp('Loop Done');
%L = length(trainingData(:,1,1));
%trainingLabels1=trainingLabels;
%trainingData = reshape(trainingData(:,:,:),L,129*11);
filename1 = strcat('C:\Users\gxs160730\Documents\Ph.D\CNN-SE\CNN-VAD\Features\Training\LPS\MACHINERY\FEATURES\HINT_test_M0','_','features');

save(filename1,'trainingData', ...
    'trainingLabels','-v7.3');
k = toc
disp('Done');
% sound(randn(1,16000),16000);
% figure;
% AA=trainingData(102,:,:);
% S=[40,40];
% BB=reshape(AA,S);
% imagesc(BB')
