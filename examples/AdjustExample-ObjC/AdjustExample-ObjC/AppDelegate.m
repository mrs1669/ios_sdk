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
    
    ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc] initWithAppToken:@"2fm9gkqubvpc"
                                                                           environment:ADJEnvironmentSandbox];
    [ADJAdjust sdkInitWithAdjustConfig:adjustConfig];

    return YES;
}

- (void)testOfflineOnlineAsync {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ADJAdjust switchToOfflineMode];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
        [ADJAdjust trackEvent:event];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ADJAdjust switchBackToOnlineMode];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
        [ADJAdjust trackEvent:event];
    });

}

- (void)testActivationAsync {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ADJAdjust inactivateSdk];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
        [ADJAdjust trackEvent:event];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ADJAdjust reactivateSdk];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ADJAdjustEvent *event = [[ADJAdjustEvent alloc] initWithEventId:@"g3mfiw"];
        [ADJAdjust trackEvent:event];
    });

}

@end
