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
    [adjustConfig setAdjustAttributionSubscriber:self];
    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];

    return YES;
}

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSLog(@"Adjust attribution read: %@", adjustAttribution);
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSLog(@"Adjust attribution changed: %@", adjustAttribution);
}

@end
