# A real-time convolutional neural network based speech enhancement for hearing impaired listeners using smartphone 

## Overview
This GitHub repository provides for Convolutional Neural Network based Speech enhancement on iOS smartphone platforms. The example app provided here is for hearing improvement studies. 

> **Abstract:** This paper presents a Speech Enhancement (SE) technique based on multi-objective learning convolutional neural network to improve the overall quality of speech perceived by Hearing Aid (HA) users. The proposed method is implemented on a smartphone as an application that performs real-time SE. This arrangement works as an assistive tool to HA. A multi-objective learning architecture including primary and secondary features uses a mapping-based convolutional neural network (CNN) model to remove noise from a noisy speech spectrum. The algorithm is computationally fast and has a low processing delay which enables it to operate seamlessly on a smartphone. The steps and the detailed analysis of real-time implementation are discussed. The proposed method is compared with existing conventional and neural network based SE techniques through speech quality and intelligibility metrics in various noisy speech conditions. The key contribution of this work includes the realization of CNN SE model on a smartphone processor that works seamlessly with HA. The experimental results demonstrate significant improvements over state of art techniques and reflect the usability of the developed SE application in noisy environments.


You can find the paper for this GitHub repository: https://ieeexplore.ieee.org/document/8735823

## Audio Demo
https://utdallas.edu/ssprl/cnn-based-speech-enhancement/

## Users Guides

[iOS](https://github.com/ssprl/Real-time-convolutional-neural-network-based-speech-enhancement/blob/master/User%20Guide-%20iOS%20CNN_SE%20final.pdf)

## Requirements 
- iPhone 7 running iOS 12.0.1
- Tensorflow 1.1x
- Frozen Model in .pb version.
- NOTE** The implementation procedure is not in use now since the tensorflow versions have changed significantly. The .pb version is no longer supported by iOS and the .tflite versions have been released. The feature extraction and training procedure can be used. Look into  for latest iOS implementation 

## License and Citation
The codes are licensed under open-source MIT license.

For any utilization of the code content of this repository, one of the following books needs to get cited by the user:

- G. S. Bhat, N. Shankar, C. K. A. Reddy and I. M. S. Panahi, "A Real-Time Convolutional Neural Network Based Speech Enhancement for Hearing Impaired Listeners Using Smartphone," in IEEE Access, vol. 7, pp. 78421-78433, 2019, doi: 10.1109/ACCESS.2019.2922370.

## Disclaimer
This work was supported in part by the National Institute of the Deafness and Other Communication Disorders (NIDCD) of the National Institutes of Health (NIH) under Award 1R01DC015430-03. The content is solely the responsibility of the authors and does not necessarily represent the official views of the NIH
