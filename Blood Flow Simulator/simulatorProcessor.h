//
//  simulatorProcessor.h
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-11.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMedia/CMBufferQueue.h>

#define MAX_NUM_FRAMES 360
#define NUM_OF_RED_AVERAGE 300

#define RECORDING_STAGE1 10
#define RECORDING_STAGE2 60
#define RED_INDEX frame_number - RECORDING_STAGE2
#define RECORDING_STAGE3 360

#define NORMALIZED_WIDTH 640
#define NORMALIZED_HEIGHT 480
@protocol simulatorProcessorDelegate;
@interface simulatorProcessor : NSObject
<AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>
{
    id <simulatorProcessorDelegate> __unsafe_unretained delegate;
    
    // Parameters
    NSMutableArray *previousSecondTimestamps;
    Float64 videoFrameRate;
    CMVideoDimensions videoDimensions;
    CMVideoCodecType videoType;
    
    // Capture session
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    AVCaptureVideoOrientation referenceOrientation;
	AVCaptureVideoOrientation videoOrientation;
	CMBufferQueueRef previewBufferQueue;
    
    // Media writer
    NSURL *movieURL;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoIn;
	dispatch_queue_t movieWritingQueue;
    
    // Action and states
    unsigned int frame_number;
    vDSP_Length frameSize;
    float RedAvg;
    size_t sumofRed, bufferWidth, bufferHeight, rowbytes;
    CGFloat currentTime;
    BOOL isUsingFrontCamera, readyToRecordAudio, readyToRecordVideo, recordingWillBeStarted, recordingWillBeStopped;
	BOOL recording;
    
    // Data storage
    vImage_Buffer inBuffer, redBuffer;
    CVPixelBufferRef yuvBufferRef;
    BOOL tmp[NORMALIZED_HEIGHT][NORMALIZED_WIDTH];
    BOOL tmp2[NORMALIZED_HEIGHT][NORMALIZED_WIDTH];
    BOOL lesstemp[NORMALIZED_HEIGHT/4][NORMALIZED_WIDTH/4];
    float tmpY[NORMALIZED_HEIGHT][NORMALIZED_WIDTH];
    
    // For calculating HR.
	float *arrayOfRedChannelAverage;
    float *arrayOfFrameRedPixels;
    float *differences;
    unsigned int sizeOfDifferences;
}

@property (readwrite, assign) id <simulatorProcessorDelegate> delegate;
// External view
@property (readonly) Float64 videoFrameRate;
@property (nonatomic, readonly) float heartRate, percentComplete;
@property (readonly) CMVideoDimensions videoDimensions;
@property (readonly) CMVideoCodecType videoType;
@property(readonly, getter=isRecording) BOOL recording;
@property (readwrite) AVCaptureVideoOrientation referenceOrientation;

+ (simulatorProcessor *) sharedProcessor;
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;

- (void) showError:(NSError*)error;

- (void) setupAndStartCaptureSession;
- (void) stopAndTearDownCaptureSession;

- (void) startRecording;
- (void) stopRecording;
- (void) pauseCaptureSession;
// Pause while recording will cause the recording to be stopped and saved.
- (void) resumeCaptureSession;

// From Narges
int detect_peak(
				const float*   data, /* the data */
				int             data_count, /* row count of data */
				//       int*            emi_peaks, /* emission peaks will be put here */
				int*            num_emi_peaks, /* number of emission peaks found */
				int             max_emi_peaks, /* maximum number of emission peaks */
				//       int*            absop_peaks, /* absorption peaks will be put here */
				int*            num_absop_peaks, /* number of absorption peaks found */
				int             max_absop_peaks, /* maximum number of absorption peaks
												  */
				float          delta,//, /* delta used for distinguishing peaks */
				//       int             emi_first /* should we search emission peak first of
				//                                  absorption peak first? */
				int*         peaks_index,
				float*         peaks_values
				);

@end
// End of interface


@protocol simulatorProcessorDelegate <NSObject>

@required
// States
- (void) pixelBufferReadyForDisplay:(CVPixelBufferRef) pixelBuffer;
- (void) recordingWillStart;
- (void) recordingDidStart;
- (void) recordingWillStop;
- (void) recordingDidStop;
// End of protocol
@end