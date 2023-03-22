//
//  ADJAttributionTracker.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJBackoffStrategy.h"
#import "ADJAttributionPackageData.h"
#import "ADJAttributionResponseData.h"
#import "ADJDelayData.h"
#import "ADJTallyCounter.h"

@interface ADJAttributionTracker : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    startsAsking:(BOOL)startsAsking;

@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

// public api
- (BOOL)sendWhenStartAsking;

- (BOOL)sendWhenSdkResumingSending;

- (void)pauseSending;

- (BOOL)sendWhenDelayEnded;

- (nullable ADJDelayData *)delaySendingWhenReceivedAttributionResponseWithData:
(nonnull ADJAttributionResponseData *)attributionResponse;

- (BOOL)tryToDelay;

@end
