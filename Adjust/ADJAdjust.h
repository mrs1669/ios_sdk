//
//  ADJAdjust.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustConfig.h"
#import "ADJAdjustEvent.h"
#import "ADJAdjustAdRevenue.h"

@interface ADJAdjust : NSObject

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
+ (void)sdkInitWithAdjustConfig:(nonnull ADJAdjustConfig *)adjustConfig;

+ (void)trackEvent:(nonnull ADJAdjustEvent *)adjustEvent;

+ (void)trackAdRevenue:(nonnull ADJAdjustAdRevenue *)adjustAdRevenue;

+ (void)inactivateSdk;
+ (void)reactivateSdk;

+ (void)switchToOfflineMode;
+ (void)switchBackToOnlineMode;

+ (void)appWentToTheForegroundManualCall;
+ (void)appWentToTheBackgroundManualCall;

@end
