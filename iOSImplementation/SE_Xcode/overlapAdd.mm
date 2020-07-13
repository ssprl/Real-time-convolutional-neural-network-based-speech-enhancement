//
//  overlapAdd.c
//  CoreAudio
//
//  Created by Shankar, Nikhil on 4/5/17.
//  Copyright © 2017 default. All rights reserved.
//

#include "overlapAdd.h"
void firFrameFilt(float * sigframe, float *FirHPb, float *frameFilterBuffer_old, int FIRHPInputFrameSize, int FilterSize,float *sigOut)
{
    //int FIRHPInputFrameSize = 440;
    
    int TotalFrameBufferLength= FIRHPInputFrameSize + FilterSize - 1;
    int FirstOverlapBufferLength = FilterSize - 1;
    int SecondSegmentBufferLength =  TotalFrameBufferLength - FirstOverlapBufferLength;
    static float *frameFilterBuffer = (float *)calloc(TotalFrameBufferLength,sizeof(float));
    static float *sigFrameBuffer = (float *)calloc(TotalFrameBufferLength, sizeof(float));
    //static float *sigOut = (float *)calloc(FIRHPInputFrameSize, sizeof(float));
    for (int i = 0; i < (int)TotalFrameBufferLength; i++)
    {
        int kmin, kmax, k;
        
        frameFilterBuffer[i] = 0;
        
        kmin = (i >= (int)FirstOverlapBufferLength + 1 - 1) ? i - ((int)FirstOverlapBufferLength + 1 - 1) : 0;
        kmax = (i < (int)SecondSegmentBufferLength - 1) ? i : (int)SecondSegmentBufferLength - 1;
        
        for (k = kmin; k <= kmax; k++)
            frameFilterBuffer[i] += sigframe[k] * FirHPb[i - k];
        
    }
    
    for (int j = 0; j < (int)FirstOverlapBufferLength; j++)
        sigFrameBuffer[j] = frameFilterBuffer_old[j] + frameFilterBuffer[j];
    
    for (int j = (int)FirstOverlapBufferLength; j < (int)TotalFrameBufferLength; j++)
        sigFrameBuffer[j] = frameFilterBuffer[j];
    int SSBL = (int)SecondSegmentBufferLength;
    for (int j = 0; j < (int)FirstOverlapBufferLength; j++)
        frameFilterBuffer_old[j] = sigFrameBuffer[SSBL + j];
    
    for (int j = 0; j < (int)SecondSegmentBufferLength; j++)
        sigOut[j] = sigFrameBuffer[j];
    
   
}
