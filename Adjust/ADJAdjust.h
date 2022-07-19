//
//  ADJAdjust.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustConfig.h"

@interface ADJAdjust : NSObject

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
+ (void)sdkInitWithAdjustConfig:(nonnull ADJAdjustConfig *)adjustConfig;

/// We can figure out below API later, once `sdkInitWithAdjustConfig` works well.
//+ (void)inactivateSdk;
//+ (void)reactivateSdk;

@end
