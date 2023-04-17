//
//  AppDelegate.h
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import <UIKit/UIKit.h>

#import "ADJAdjust.h"
#import "ADJAdjustAttributionCallback.h"
#import "ADJAdjustAttributionSubscriber.h"
#import "ADJAdjustLaunchedDeeplinkCallback.h"
#import "ADJAdjustCallback.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ADJAdjustAttributionSubscriber, ADJAdjustLaunchedDeeplinkCallback>

@property (strong, nonatomic) UIWindow *window;

@end

