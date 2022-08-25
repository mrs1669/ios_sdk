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

+ (void)addGlobalCallbackParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
+ (void)removeGlobalCallbackParameterByKey:(nonnull NSString *)key;
+ (void)clearAllGlobalCallbackParameters;

+ (void)addGlobalPartnerParameterWithKey:(nonnull NSString *)key
                                    value:(nonnull NSString *)value;
+ (void)removeGlobalPartnerParameterByKey:(nonnull NSString *)key;
+ (void)clearAllGlobalPartnerParameters;

@end
