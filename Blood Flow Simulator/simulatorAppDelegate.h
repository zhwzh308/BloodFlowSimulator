//
//  simulatorAppDelegate.h
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-10.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class simulatorViewController;

@interface simulatorAppDelegate : UIResponder <UIApplicationDelegate> {
    simulatorViewController *simulatorVC;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) simulatorViewController *simulatorVC;

@end
