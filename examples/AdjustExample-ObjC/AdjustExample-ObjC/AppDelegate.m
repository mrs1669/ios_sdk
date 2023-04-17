//
//  AppDelegate.m
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import "AppDelegate.h"

#import "ADJAdjust.h"
#import "ADJAdjustInstance.h"
#import "ADJAdjustConfig.h"
#import "ADJAdjustLaunchedDeeplink.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    ADJAdjustConfig *_Nonnull adjustConfig = [[ADJAdjustConfig alloc]
                                              initWithAppToken:@"2fm9gkqubvpc"
                                              environment:ADJEnvironmentSandbox];
    [adjustConfig doLogAll];
    [adjustConfig setAdjustAttributionSubscriber:self];
    [adjustConfig setExternalDeviceId:@"test-ext-device-id"];
    [[ADJAdjust instance] initSdkWithConfig:adjustConfig];
    [[ADJAdjust instance] adjustLaunchedDeeplinkWithCallback:self];
    [[ADJAdjust instance] trackLaunchedDeeplink:[[ADJAdjustLaunchedDeeplink alloc]
                                                 initWithString:@"https://github.com/"]];
    return YES;
}

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSLog(@"Adjust Attribution Read: %@", adjustAttribution);
}

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    NSLog(@"Adjust Attribution Changed: %@", adjustAttribution);
}

- (void)didFailWithMessage:(NSString *)message {
    NSLog(@"Adjust Fail Message: %@", message);
}

- (void)didReadWithAdjustLaunchedDeeplink:(nonnull NSURL *)adjustLaunchedDeeplink {
    NSLog(@"Adjust Launched Deeplink: %@", adjustLaunchedDeeplink);
}

@end


