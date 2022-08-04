//
//  AppDelegate.m
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 13/07/22.
//

#import "AppDelegate.h"

#import <Adjust/ADJAdjust.h>
#import <Adjust/ADJAdjustEvent.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ADJAdjustConfig *_Nonnull adjustConfig =
    [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc"
                                  environment:ADJEnvironmentSandbox];
    
    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];
    
    ADJAdjustEvent *event = [[ADJAdjustEvent alloc]
                             initWithEventId:@"g3mfiw"];
    [ADJAdjust trackEvent:event];
    
    return YES;
}

@end
