//
//  FIR.h
//  CoreAudio
//
//  Created by Shankar, Nikhil on 4/4/17.
//  Copyright © 2017 default. All rights reserved.
//

#ifndef FIR_h
#define FIR_h
#include "Transforms.h"
#include <stdio.h>
void fir(float* input, float* output, int nSamples);
void jmap(float* input, float* output, int nSamples, int Srate, float beta);

#endif /* FIR_h */
