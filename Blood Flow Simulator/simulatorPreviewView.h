//
//  simulatorPreviewView.h
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-11.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>

@interface simulatorPreviewView : UIView
{
    int renderBufferWidth, renderBufferHeight;
    // OpenGLES texture cache
    CVOpenGLESTextureCacheRef videoTextureCache;
    // In a EAGLContext
    EAGLContext *oglContext;
    
    // All the GL parameters
    GLuint frameBufferHandle, colorBufferHandle, passThroughProgram;
}

- (void) displayPixelBuffer: (CVImageBufferRef)pixelBuffer;

@end
