//
//  simulatorViewController.h
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-10.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "simulatorProcessor.h"
#import "simulatorPreviewView.h"

@interface simulatorViewController : UIViewController <simulatorProcessorDelegate>
{
    simulatorProcessor *videoProcessor;
    
    UIView *previewView;
    simulatorPreviewView *oglView;
    UIBarButtonItem *recordButton;
    UILabel *frameRateLabel;
    UILabel *dimensionsLabel;
    UILabel *typeLabel;
    
    NSTimer *timer;
    UIBackgroundTaskIdentifier backgroundRecordingID;
}

@property (nonatomic) IBOutlet UIView *previewView;
@property (nonatomic) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic) id statsObserveToken;
@property (readwrite) BOOL shouldShowStats;

- (IBAction)toggleRecording:(id)sender;
- (IBAction)switchLabel:(id)sender;

@end
