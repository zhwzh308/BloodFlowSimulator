//
//  simulatorViewController.m
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-10.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "simulatorViewController.h"

@interface simulatorViewController ()

@end

@implementation simulatorViewController
@synthesize previewView;
@synthesize recordButton;
@synthesize shouldShowStats;

- (void)updateLabels
{
	if (shouldShowStats) {
        // Get framerate from videoProcessor
        NSString *frameRateString = nil;
		NSString *dimensionsString = nil;
        if ([videoProcessor heartRate]) {
            frameRateString = [NSString stringWithFormat:@"%.2f FPS ", [videoProcessor videoFrameRate]];
            dimensionsString = [NSString stringWithFormat:@"%.0f BPM ", [videoProcessor heartRate]];
        }
        else {
            float result = [videoProcessor percentComplete] *100.0f;
            if (result >= 0.0f) {
                frameRateString = [NSString stringWithFormat:@"Detecting %.0f%%", result];
            } else {
                frameRateString = [NSString stringWithFormat:@"Warming up..."];
            }
            dimensionsString = [NSString stringWithFormat:@"Lightly press the back camera."];
        }
        
 		frameRateLabel.text = frameRateString;
 		dimensionsLabel.text = dimensionsString;
        if ([videoProcessor heartRate]) {
            [dimensionsLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.25]];
        } else {
            [dimensionsLabel setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25]];
        }
        if ([videoProcessor videoFrameRate] >= 20.0f) {
            [frameRateLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25]];
        } else {
            [frameRateLabel setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25]];
        }
 		
 	}
 	else {
 		frameRateLabel.text = @"";
 		[frameRateLabel setBackgroundColor:[UIColor clearColor]];
 		
 		dimensionsLabel.text = @"";
 		[dimensionsLabel setBackgroundColor:[UIColor clearColor]];
 	}
}

- (UILabel *)labelWithText:(NSString *)text yPosition:(CGFloat)yPosition
{
    // Bound the label, 200x40
	CGFloat labelWidth = 240.0;
	CGFloat labelHeight = 30.0;
	CGFloat xPosition = previewView.bounds.size.width - labelWidth - 10;
	CGRect labelFrame = CGRectMake(xPosition, yPosition, labelWidth, labelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    // 36 originally.
	[label setFont:[UIFont systemFontOfSize:18]];
	[label setLineBreakMode:NSLineBreakByWordWrapping];
	[label setTextAlignment:NSTextAlignmentRight];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
	[[label layer] setCornerRadius: 4];
	[label setText:text];
	
	return label;
}

// UIDeviceOrientationDidChangeNotification selector
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[videoProcessor setReferenceOrientation:(AVCaptureVideoOrientation)orientation];
}

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Initialize the class responsible for managing AV capture session and asset writer
    videoProcessor = [[simulatorProcessor alloc] init];
	videoProcessor.delegate = self;
    
	// Keep track of changes to the device orientation so we can update the video processor
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // Setup and start the capture session
    [videoProcessor setupAndStartCaptureSession];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Allocate OpenGL (PreviewView) view
	oglView = [[simulatorPreviewView alloc] initWithFrame:CGRectZero];
    
	oglView.transform = [videoProcessor transformFromCurrentVideoOrientationToOrientation:AVCaptureVideoOrientationPortrait];
    // Squeeze CIContext.
    // ciContext = [[CIContext init]]
    [previewView addSubview:oglView];
    
 	CGRect bounds = CGRectZero;
 	bounds.size = [self.previewView convertRect:self.previewView.bounds toView:oglView].size;
    
 	oglView.bounds = bounds;
    oglView.center = CGPointMake(previewView.bounds.size.width/2.0, previewView.bounds.size.height/2.0);
 	
 	// Set up labels, usse NO to turn this function off.
	shouldShowStats = YES;
	// Where to display these labels.
	frameRateLabel = [self labelWithText:@"" yPosition: (CGFloat) 30.0];
	[previewView addSubview:frameRateLabel];
	
	dimensionsLabel = [self labelWithText:@"" yPosition: (CGFloat) 75.0];
	[previewView addSubview:dimensionsLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanup
{
	//[oglView release];
	oglView = nil;
    
    frameRateLabel = nil;
    dimensionsLabel = nil;
    //typeLabel = nil;
	
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Stop and tear down the capture session
	[videoProcessor stopAndTearDownCaptureSession];
	videoProcessor.delegate = nil;
    //[videoProcessor release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[timer invalidate];
	timer = nil;
}

- (IBAction)toggleRecording:(id)sender {
    // Wait for the recording to start/stop before re-enabling the record button.
	[[self recordButton] setEnabled:NO];
	// Very simple two states.
	if ( [videoProcessor isRecording] ) {
		// The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
		[videoProcessor stopRecording];
	}
	else {
		// The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [videoProcessor startRecording];
	}
}

- (IBAction)switchLabel:(id)sender {
    shouldShowStats = !shouldShowStats;
}

#pragma mark simulatorProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:NO];
		[[self recordButton] setTitle:@"Stop"];
        
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
		[[self recordButton] setTitle:@"Record"];
		[[self recordButton] setEnabled:NO];
		
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		[videoProcessor pauseCaptureSession];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
        
		[videoProcessor resumeCaptureSession];
        
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
	if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
		[oglView displayPixelBuffer:pixelBuffer];
}

@end
