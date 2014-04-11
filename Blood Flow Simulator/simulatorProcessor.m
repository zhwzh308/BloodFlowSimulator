//
//  simulatorProcessor.m
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-11.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import "simulatorProcessor.h"

@implementation simulatorProcessor

// Singleton processor
+ (simulatorProcessor *) sharedProcessor {
    static simulatorProcessor *_sharedInstance = nil;
    
    static dispatch_once_t onePredicate;
    
    dispatch_once(&onePredicate, ^{
        _sharedInstance = [[simulatorProcessor alloc]init];
    });
    return _sharedInstance;
}

@end
