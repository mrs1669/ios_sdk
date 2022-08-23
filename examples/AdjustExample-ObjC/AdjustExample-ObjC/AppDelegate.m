//
//  AppDelegate.m
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import "AppDelegate.h"

#import "ADJAdjust.h"
#import "ADJAdjustEvent.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc"
                                                                           environment:ADJEnvironmentSandbox];
    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];

    return YES;
}

@end
