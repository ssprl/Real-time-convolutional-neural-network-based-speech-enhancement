//
//  ViewController.h
//  CoreAudio
//
//  Created by Shankar, Nikhil on 4/4/17.
//  Copyright © 2017 default. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>


@interface ViewController : UIViewController{

@public
float x,y;
float *speechPrediction [129];
    

}


@property (weak,nonatomic) IBOutlet UILabel *betaLabel;
@property (weak, nonatomic) IBOutlet UISwitch *EnhancedSwitch;
@property (weak, nonatomic) IBOutlet UISlider *betaSlider;
@property (strong, nonatomic) IBOutlet UIButton *setBeta;

@property (strong, nonatomic) IBOutlet UIStepper *stepper;

@property (strong, nonatomic) IBOutlet UILabel *snrdisplay;

- (IBAction)snr:(id)sender;


- (IBAction)buttonPressed:(id)sender;
- (IBAction)SwitchPressed:(id)sender;
- (IBAction)betaValue:(id)sender;

- (IBAction)stepbeta:(id)sender;


@end

