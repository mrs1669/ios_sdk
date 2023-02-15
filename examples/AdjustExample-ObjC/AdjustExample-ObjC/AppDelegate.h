//
//  AppDelegate.h
//  AdjustExample-ObjC
//
//  Created by Aditi Agrawal on 23/08/22.
//

#import <UIKit/UIKit.h>
#import "ADJAdjustAttributionSubscriber.h"

#import "ADJAdjust.h"
#import "ADJAdjustAttributionCallback.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ADJAdjustAttributionCallback>

@property (strong, nonatomic) UIWindow *window;

@end

