//
//  ADJGdprForgetTracker.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJTallyCounter.h"
#import "ADJBackoffStrategy.h"
#import "ADJDelayData.h"
#import "ADJGdprForgetResponseData.h"

@interface ADJGdprForgetTracker : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    gdprForgetBackoffStrategy:(nonnull ADJBackoffStrategy *)gdprForgetBackoffStrategy
    startsAsking:(BOOL)startsAsking;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

// public api
- (BOOL)sendWhenStartTracking;

- (BOOL)resumeSendingWhenAppWentToForeground;
- (void)pauseSendingWhenAppWentToBackground;

- (BOOL)sendWhenDelayEnded;

- (nullable ADJDelayData *)
    delayTrackingWhenReceivedGdprForgetResponseWithData:
        (nonnull ADJGdprForgetResponseData *)gdprForgetResponse;

@end
