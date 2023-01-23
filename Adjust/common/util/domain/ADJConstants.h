//
//  ADJConstants.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT double const ADJSecondToMilliDouble;
FOUNDATION_EXPORT NSUInteger const ADJMilliToMicro;
FOUNDATION_EXPORT NSUInteger const ADJMilliToNano;

FOUNDATION_EXPORT NSUInteger const ADJOneSecondMilli;
FOUNDATION_EXPORT NSUInteger const ADJTenSecondsMilli;
FOUNDATION_EXPORT NSUInteger const ADJOneMinuteMilli;
FOUNDATION_EXPORT NSUInteger const ADJThirtyMinutesMilli;
FOUNDATION_EXPORT NSUInteger const ADJOneHourMilli;

FOUNDATION_EXPORT NSString *const ADJAdjustSubSystem;
FOUNDATION_EXPORT NSString *const ADJAdjustCategory;

FOUNDATION_EXPORT NSString *const ADJAppAdjustUrl;
FOUNDATION_EXPORT NSString *const ADJGdprAdjustUrl;
FOUNDATION_EXPORT NSString *const ADJSubscriptionAdjustUrl;

FOUNDATION_EXPORT NSUInteger const ADJInitialHashCode;
FOUNDATION_EXPORT NSUInteger const ADJHashCodeMultiplier;

FOUNDATION_EXPORT NSUInteger const ADJDefaultMaxCapacityEventDeduplication;

// IoData metadata
FOUNDATION_EXPORT NSString *const ADJMetadataVersionKey;
FOUNDATION_EXPORT NSString *const ADJMetadataVersionValue;
FOUNDATION_EXPORT NSString *const ADJMetadataIoDataTypeKey;
FOUNDATION_EXPORT NSString *const ADJMetadataMapName;
FOUNDATION_EXPORT NSString *const ADJPropertiesMapName;

// default starting states
FOUNDATION_EXPORT const BOOL ADJIsSdkPausedWhenStarting;
FOUNDATION_EXPORT const BOOL ADJIsSdkInForegroundWhenStarting;
FOUNDATION_EXPORT const BOOL ADJIsSdkActiveWhenStarting;
FOUNDATION_EXPORT const BOOL ADJIsSdkForgottenWhenStarting;
FOUNDATION_EXPORT const BOOL ADJIsSdkOfflineWhenStarting;
FOUNDATION_EXPORT const BOOL ADJIsNetworkReachableWhenStarting;

NS_ASSUME_NONNULL_END
