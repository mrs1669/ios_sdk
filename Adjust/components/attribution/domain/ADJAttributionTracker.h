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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAskingAttributionStatusFromBackend;
FOUNDATION_EXPORT NSString *const ADJAskingAttributionStatusFromSdk;
FOUNDATION_EXPORT NSString *const ADJAskingAttributionStatusFromBackendAndSdk;

NS_ASSUME_NONNULL_END

@interface ADJAttributionTracker : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                   attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy;

@property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;

// public api
- (BOOL)canSendWhenAskingWithAskingAttribution:(nonnull NSString *)askingAttribution;

- (void)stopAsking;

- (BOOL)sendWhenSdkResumingSending;

- (void)pauseSending;

- (BOOL)sendWhenDelayEnded;

- (nullable ADJDelayData *)delaySendingWhenReceivedAttributionResponseWithData:
(nonnull ADJAttributionResponseData *)attributionResponse;

- (BOOL)canDelay;

- (nullable ADJAttributionPackageData *)attributionPackage;

- (nullable NSString *)initiatedBy;

- (void)setAttributionPackageToSendWithData:
(nonnull ADJAttributionPackageData *)attributionPackageToSend;

@end
