//
//  ViewController.m
//  CoreAudio
//
//  Created by Shankar, Nikhil on 4/4/17.
//  Copyright © 2017 default. All rights reserved.
//

#import "ViewController.h"
#import "FIR.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#import <tensorflow/core/public/session.h>
#include "data1.h"
#include "FIRFilter.h"
#define DECIMATION_FACTOR 6
#define kOutputBus 0
#define kInputBus 1
#define SHORT2FLOAT 1/32768.0
#define FLOAT2SHORT 32768.0;
#define FRAMESIZE 128
#define FRAMEDOWNSIZE 128
#define SAMPLINGFREQUENCY 8000
#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

#ifndef let
#define let __auto_type const
#endif

#ifndef guard
#define guard(CONDITION) \
if (CONDITION) {}
#endif

//#import "frozen_cnn_se_i.h"


//int decimatedStepSize = FRAMESIZE/DECIMATION_FACTOR;
//
//static float *downsampled = (float*)calloc(FRAMESIZE, sizeof(float));
//static float *decimated   = (float*)calloc(2*decimatedStepSize, sizeof(float));
//
//FIR *downsampleFilter = initFIR(FRAMESIZE);

int nFFT=256;
//static float endSamples[3] = {0,0,0};
//int FFT=1024;
//static float *magnitudeRight =(float*)calloc(nFFT/2, sizeof(float));
//static float *magnitudeLeft =(float*)calloc(nFFT/2, sizeof(float));
//static float *data1 = (float*)calloc(FRAMEUPSIZE, sizeof(float));
static float *noise_mean = (float*)calloc(nFFT, sizeof(float));
static float *noise_mu2 = (float*)calloc(nFFT, sizeof(float));
static float *sig2 = (float*)calloc(nFFT, sizeof(float));
static float *gammak = (float*)calloc(nFFT, sizeof(float));
static float *ksi = (float*)calloc(nFFT, sizeof(float));
static float *Xk_prev = (float*)calloc(nFFT, sizeof(float));
static float *log_sigma_k = (float*)calloc(nFFT, sizeof(float));
static float *noise_pow = (float*)calloc(nFFT, sizeof(float));
static float *vk = (float*)calloc(nFFT, sizeof(float));
static float *hw = (float*)calloc(nFFT, sizeof(float));
static float *evk = (float*)calloc(nFFT, sizeof(float));
static float *Lambda = (float*)calloc(nFFT, sizeof(float));
static float *pSAP = (float*)calloc(nFFT, sizeof(float));
static float* ensig = ( float *)calloc(nFFT, sizeof( float));
static float* HPF = ( float*)calloc(2*(nFFT), sizeof( float));
static float* H = ( float*)calloc((nFFT), sizeof( float));
static float *fftmagoutput = (float*)calloc(nFFT, sizeof(float));
static float *angle = (float*)calloc(nFFT, sizeof(float));
static float *output_image = (float*)calloc(129, sizeof(float));

static float *output_ff = (float*)calloc(96000, sizeof(float));

//static float *phase = (float*)calloc(nFFT, sizeof(float));
//static float *h=(float*)calloc(nFFT,sizeof(float));
//long double* nsig = (long double *)calloc(nFFT, sizeof(long double));
float input_image[129][11];
float input_new_image[129][11];
float total_noisepower=0;
float total_speechpower=0;
float sum_ensig = 0;
float sum_nsig = 0;
float PRT;
float N;
float aa = 0.98;
float eta = 0.15;
float beta=0.5;
float max;
float ksi_min = (float)pow(10,((float)-25 /(float)10));
float sum_log_sigma_k = 0;
float vad_decision;
float qk = 0.3;
float qkr = (1 - qk) / qk;;
//float epsilon =  (float)pow(8.854,-12);
float epsilon = 0.001;
//float total_noisepower=0;
//float total_speechpower=0;
////float SNR_db;
char SNR_db_char;
int count=0;
int SPU = 0;
static float SNR_db;
//float *magnitudeLeft, *magnitudeRight, *phaseLeft, *phaseRight, *fifoOutput;
//float sum_ensig;
//float beta;
int on;
int frameCounter=0;
float snr_counter=0;
float sum_SNR=0;
float snr_avg;
Transform *X;
Transform *Y;
int k=1;
float np,sp;
float *win = (float*)malloc(nFFT* sizeof(float));
float *sys_win = (float*)malloc(FRAMESIZE* sizeof(float));
static float *output_final = (float*)calloc(FRAMESIZE, sizeof(float));
static float *output_old = (float*)calloc(FRAMESIZE, sizeof(float));
static float *in_buffer = (float*)calloc(nFFT, sizeof(float));
static float *in_prev = (float*)calloc(FRAMESIZE, sizeof(float));


int Nframes = 749;


//static float *phase = (float*)calloc(nFFT, sizeof(float));
static float *input = (float*)calloc(FRAMESIZE, sizeof(float));
static float *float_output = (float*)calloc(FRAMESIZE, sizeof(float));

//static short *buffer = (short*)calloc(FRAMESIZE/sizeof(short), sizeof(short));
//static short *output = (short*)calloc(FRAMESIZE/sizeof(short), sizeof(short));

AURenderCallbackStruct callbackStruct;
AudioUnit au;
AudioBuffer tempBuffer;

@interface ViewController ()

@end

@implementation ViewController {
    tensorflow::GraphDef graph;
    tensorflow::Session *session;
    
}

@synthesize betaSlider;
@synthesize EnhancedSwitch;
@synthesize betaLabel;
@synthesize setBeta;
@synthesize stepper;
@synthesize snrdisplay;


-(void) updateBeta{
    x=stepper.value;
     betaLabel.text=[ NSString stringWithFormat:@"%f",x];
    
}

-(void) updateBeta1{
    x = 0.7;
    betaLabel.text=[ NSString stringWithFormat:@"%f",0.9];
    betaSlider.value = 0.9;
}

// Input Tensor





static OSStatus playbackCallback(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    for (int i=0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer buffer = ioData->mBuffers[i];
        UInt32 size = min(buffer.mDataByteSize, tempBuffer.mDataByteSize);
        memcpy(buffer.mData, tempBuffer.mData, size);
        buffer.mDataByteSize = size;
    }
    return noErr;
}

static OSStatus recordingCallback(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    AudioBuffer buffer;
    ViewController* view = (__bridge ViewController *)(inRefCon);
    
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumberFrames * 2;
    buffer.mData = malloc( inNumberFrames * 2 );
    
    // Put buffer in a AudioBufferList
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    AudioUnitRender(au, ioActionFlags, inTimeStamp,inBusNumber,inNumberFrames,&bufferList);
    
    [view processAudio:&bufferList];
    // printf("%f\n",buffer);
    
    return noErr;
}

//@implementation ViewController {
//    tensorflow::GraphDef graph;
//    tensorflow::Session *session;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    betaLabel.text = @"0.5";
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: NULL];
    [[AVAudioSession sharedInstance] setMode: AVAudioSessionModeVideoRecording error:NULL];
    [[AVAudioSession sharedInstance] setPreferredSampleRate:SAMPLINGFREQUENCY error:NULL];
    [[AVAudioSession sharedInstance]
     setPreferredIOBufferDuration:(float)FRAMESIZE/(float)SAMPLINGFREQUENCY error:NULL];
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent component = AudioComponentFindNext(NULL, &desc);
    if (AudioComponentInstanceNew(component, &au) != 0) abort();
    
    UInt32 value = 1;
    if (AudioUnitSetProperty(au, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &value,
                             sizeof(value))) abort();
    value = 1;
    if (AudioUnitSetProperty(au, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &value,
                             sizeof(value))) abort();
    
    AudioStreamBasicDescription format;
    format.mSampleRate = 0;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = 1;
    format.mBitsPerChannel = 16;
    format.mBytesPerPacket = 2;
    format.mBytesPerFrame = 2;
    
    if (AudioUnitSetProperty(au, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format,
                             sizeof(format))) abort();
    if (AudioUnitSetProperty(au, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &format,
                             sizeof(format))) abort();
    // Set input callback
    
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    AudioUnitSetProperty(au, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus,  &callbackStruct, sizeof(callbackStruct));
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    AudioUnitSetProperty(au, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, kOutputBus,&callbackStruct, sizeof(callbackStruct));
    tempBuffer.mNumberChannels = 1;
    tempBuffer.mDataByteSize = FRAMESIZE * 2;
    tempBuffer.mData = malloc( FRAMESIZE * 2 );
    AudioUnitInitialize(au);
    AudioOutputUnitStart(au);
       // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)loadGraphFromPath:(NSString *)path {
    
    auto status = ReadBinaryProto(tensorflow::Env::Default(), path.fileSystemRepresentation, &graph);
    if (!status.ok()) {
        NSLog(@"Error reading graph: %s", status.error_message().c_str());
        return NO;
    }
    
    // This prints out the names of the nodes in the graph.
    auto nodeCount = graph.node_size();
    //NSLog(@"Node count: %d", nodeCount);
    for (auto i = 0; i < nodeCount; ++i) {
        auto node = graph.node(i);
        //NSLog(@"Node %d: %s '%s'", i, node.op().c_str(), node.name().c_str());
    }
    
    return YES;
}


- (BOOL)createSession {
    tensorflow::SessionOptions options;
    auto status = tensorflow::NewSession(options, &session);
    if (!status.ok()) {
        NSLog(@"Error creating session %s",
              status.error_message().c_str());
        return NO;
    }
    
    status = session->Create(graph);
    if (!status.ok()) {
        NSLog(@"Error adding graph to session: %s",
              status.error_message().c_str());
        return NO;
    }
    return YES;
}


- (void)predict {
    
    tensorflow::Tensor x(tensorflow::DT_FLOAT,
                         tensorflow::TensorShape({ 129, 11 }));
    auto input  = x.tensor<float, 2>();
    
    for (int i = 0; i < 129; i++) {
        for (int j = 0; j < 11; j++) {
            input(i, j) = input_new_image[i][j];
        }
    }
    std::vector<std::pair<std::string, tensorflow::Tensor>> inputs = {
        {"x-input", x},
    };
    std::vector<std::string> nodes = {
        {"output_t"}
    };
    std::vector<tensorflow::Tensor> outputs;

    auto status = session->Run(inputs, nodes, {}, &outputs);
    if(!status.ok()) {
        NSLog(@"Error running model: %s", status.error_message().c_str());
        return;
    }
    
    auto pred = outputs[0].tensor<float, 2>();
    //std::cout<<pred;
    for(int i=0;i<129;i++)
        output_image[i]=pred(i);
    
    

//    for (int i = 0; i < 129; i++) {
//            pred(i) = ;
//        }
    //return output_image;
    }


-(void) processAudio: (AudioBufferList*) bufferList{
   // let model = frozen_cnn_se_i();
    //model = [[[frozen_cnn_se_i alloc] init] model];

    AudioBuffer sourceBuffer = bufferList->mBuffers[0];
   // short *buffer = (short*)calloc(sourceBuffer.mDataByteSize);
    //short *output =(short*)calloc(sourceBuffer.mDataByteSize);
    //printf("%f\n",predict);

  
   // NSArray *array = [NSArray arrayWithArray:pred];
    for (int i = 0; i < nFFT; i++)
    {
        win[i] = 0.5 * (1 - cosf(2 * M_PI*(i + 1) / (nFFT + 1)));
    }
    for (int i = 0; i < FRAMEDOWNSIZE; i++)
    {
        sys_win[i] = 1 / (win[i] + win[i + FRAMEDOWNSIZE]);
    }
    
   // static float *input1 = (float*)calloc(nFFT, sizeof(float));
   // static float *store_buffer = (float*)calloc(FRAMESIZE, sizeof(float));
    static short *buffer = (short*)calloc(sourceBuffer.mDataByteSize/sizeof(short), sizeof(short));
    static short *output = (short*)calloc(sourceBuffer.mDataByteSize/sizeof(short), sizeof(short));
    //static float *float_output1 = (float*)calloc(nFFT, sizeof(float));

    memcpy(buffer, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
    
    for (int i = 0; i < FRAMESIZE; i++) {
        input[i] = buffer[i] * SHORT2FLOAT;
       // printf("%f\n",input[i]);
    }
 if(on==0)
    {

        for(int i =0;i<FRAMESIZE;i++)
        {
        float_output[i]=input[i];
    }
        
        //fir(input,float_output,FRAMESIZE);
    }




 if(on==1)
    {
        //FIR *downsampleFilter = initFIR(FRAMEDOWNSIZE);

        frameCounter++;
        int k1=0;
        int kff=0;
        for (int framecount=0;framecount<Nframes;framecount++)
       {
           for(int i=0;i<FRAMESIZE;i++)
          {
               input[i]=train[k1];
               k1++;
           }
//            for(int i=0;i<FRAMESIZE;i++)
//            {
//        printf("%.32lf\n",input[i]);
//            }
       // processFIRFilter(downsampleFilter, input, downsampled);
        
        // Decimate the audio
//        for (int i = 0, j = 0; i < decimatedStepSize; i++, j+= 6) {
//            //decimated[i] = decimated[i+decimatedStepSize];
//            decimated[i] = downsampled[j];
       
        X=newTransform(nFFT);
        Y=newTransform(nFFT);
        X->doTransform(X,in_buffer);
        transformMagnitude(X, fftmagoutput);
        
        for(int i =0;i<FRAMEDOWNSIZE;i++)
        {
//            in_buffer[i]=in_prev[i] * win[i];
//            in_prev[i]=decimated[i];
//            in_buffer[i+FRAMESIZE]=decimated[i] * win[i+FRAMESIZE];
            in_buffer[i]=in_prev[i]* win[i] ;
            in_prev[i]=input[i];
            in_buffer[i+FRAMEDOWNSIZE]=input[i]* win[i+FRAMEDOWNSIZE] ;
            
        }
        if (framecount==1)
        {
            
            NSString* source = [[NSBundle mainBundle] pathForResource:@"frozentensorflowModel" ofType:@"pb"];
            if(!source){
                NSLog(@"Unable to find file in the bundle");
            }
            else {
                // Load Tensorflow model
                [self loadGraphFromPath:source];

                // Create Tensorflow session
                [self createSession];
            }
            for(int i = 0; i<nFFT/2+1; i++)
            {
                for(int j=0;j<11;j++)
                {
                    input_image[i][j] = 0;
                    input_new_image[i][j] = 0;
                }
            }
            for(int i =0;i<FRAMESIZE;i++)
            {
                float_output[i]=input[i];
            }
        }
    
        if (framecount>1&&framecount<13)
        {
            for(int i=0;i<256;i++)
            {
               // printf("%.32lf\n",in_buffer[i]);
            }
            for(int i =0;i<FRAMESIZE;i++)
            {
                float_output[i]=input[i];
            }
        
        for(int i =0;i<FRAMEDOWNSIZE+1;i++)
        {
            fftmagoutput[i] = 20 * log10(fftmagoutput[i]);
            //printf ("%.32lf\n",fftmagoutput[i]);
        }
           
        for (int i=0;i<FRAMEDOWNSIZE+1;i++)
        {
            input_image[i][frameCounter-1]=fftmagoutput[i];
        }
            
        }
        if(framecount>12&&framecount<Nframes+1)
        {
           
            for (int i=0;i<nFFT;i++)
            {
                angle[i]= atan2(X->imaginary[i],X->real[i]);
            }
            for(int j=0;j<10;j++)
            {
                for(int i=0;i<129;i++)
                {
                    input_new_image[i][j]=input_image[i][j+1];
                    //input_image[i][j]=input_new_image[i][j];
                }
            }
                for(int i=0;i<129;i++)
                {
                    input_new_image[i][10]=20 * log10(fftmagoutput[i]);
                }
         
            for(int j=0;j<11;j++)
            {
                for(int i=0;i<129;i++)
                {
                    input_image[i][j]=input_new_image[i][j];
                
                   // printf("%.32lf\n",input_new_image[i][j]);
                    //input_image[i][j]=input_new_image[i][j];
                }
                //printf("%d\n",j);
            }
            for(int i=0;i<129;i++)
            {
                //printf("%.32lf\n",input_new_image[i][10]);
            }
            
            
            //guard(let marsHabitatPricerOutput = try? model.prediction(x-input:input_image);
            
            
            
            [self predict];
         
            //for(int i=0;i<129;i++)
           // printf("%d\n",framecount);
            
            for(int i=0;i<FRAMEDOWNSIZE+1;i++)
            {
                fftmagoutput[i]=output_image[i];
            }
            int j=FRAMEDOWNSIZE-1;
            for(int i=0;i<FRAMEDOWNSIZE-1;i++)
            {
            fftmagoutput[i+FRAMEDOWNSIZE+1]=output_image[j];
            j--;
            }
            for(int i=0;i<nFFT;i++)
            {
                fftmagoutput[i]=pow(10,fftmagoutput[i]/20);
               // printf("%.32lf %d\n",fftmagoutput[i],i);
            }
            for(int i=0;i<nFFT;i++)
            {
                
               // printf("%.32lf %d\n",fftmagoutput[i],i);
            }
            for(int i=0;i<nFFT;i++)
            {
                X->real[i]=fftmagoutput[i]*cos(angle[i]);
                X->imaginary[i]=fftmagoutput[i]*sin(angle[i]);
            }



        Y->invTransform(Y,X->real,X->imaginary);
        sp=Y->real[0];
//        for(int i=1;i<FRAMESIZE;i++)
//        {
//            if(Y->real[i]>sp)
//            {
//                sp=Y->real[i];
//            }
//        }
//        for(int i=0;i<nFFT;i++)
//        {
//            SNR_db+=gammak[i];
//        }
//        SNR_db=(log10(total_noisepower/total_speechpower))-2;
            for(int i=0;i<FRAMEDOWNSIZE;i++)
            {
                output_final[i]=(output_old[i]+Y->real[i])*sys_win[i];
                output_old[i]=Y->real[i+FRAMEDOWNSIZE];
            }
            for(int i=0;i<FRAMESIZE;i++)
            {
                float_output[i]=input[i];
                //float_output[i]=output_final[i];
               // printf("%.32lf\n",input[i]);
            }

//        for(int i=0;i<FRAMESIZE;i++)
//        {
//            output_final[i]=(output_old[i]+Y->real[i])*sys_win[i];
//            output_old[i]=Y->real[i+FRAMESIZE];
//        }
            for(int i=0;i<FRAMESIZE;i++)
            {
                output_ff[kff]=output_final[i];
                kff++;
            }



       //fir(output_final,float_output,FRAMESIZE);



        destroyTransform(X);
        destroyTransform(Y);
        
    }
    }
    
        for(int i=0;i<96000;i++)
        {

            printf("%.32lf\n",output_ff[i]);
        }
   }

        for (int i = 0; i < FRAMESIZE; i++)
        {
        float_output[i]=float_output[i]*2;
        output[i] = float_output[i] * FLOAT2SHORT ;
        //output[i]=output[i]*3;
        //printf("%f\n",float_output[i]);
        }
    
    if (tempBuffer.mDataByteSize != sourceBuffer.mDataByteSize)
    {
        free(tempBuffer.mData);
        tempBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
        tempBuffer.mData = malloc(sourceBuffer.mDataByteSize);
    }
    memcpy(tempBuffer.mData, output, bufferList->mBuffers[0].mDataByteSize);
    

}

-(void) updatesnr{
    y=SNR_db;
    snrdisplay.text=[ NSString stringWithFormat:@"%f",y];
    
}

- (IBAction)snr:(id)sender {
    [self updatesnr];
}

- (IBAction)buttonPressed:(id)sender {
    [self updateBeta1];
    
}

- (IBAction)SwitchPressed:(id)sender
{
    if(EnhancedSwitch.on)
    {
        on=1;
    }
    else
    {
        on=0;
    }
}

- (IBAction)betaValue:(id)sender {
    [self updateBeta];
}

- (IBAction)stepbeta:(id)sender {
    [self updateBeta];
}

                  
                  
@end
