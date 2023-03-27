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

FOUNDATION_EXPORT NSString *const ADJAppleUUIDZeros;

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

// logging
FOUNDATION_EXPORT NSString *const ADJLogMessageKey;
FOUNDATION_EXPORT NSString *const ADJLogLevelKey;
FOUNDATION_EXPORT NSString *const ADJLogIssueKey;
FOUNDATION_EXPORT NSString *const ADJLogParamsKey;
FOUNDATION_EXPORT NSString *const ADJLogLoggerNameKey;
FOUNDATION_EXPORT NSString *const ADJLogCallerThreadIdKey;
FOUNDATION_EXPORT NSString *const ADJLogRunningThreadIdKey;
FOUNDATION_EXPORT NSString *const ADJLogFromCallerKey;
FOUNDATION_EXPORT NSString *const ADJLogInstanceIdKey;
FOUNDATION_EXPORT NSString *const ADJLogIsPreSdkInitKey;
FOUNDATION_EXPORT NSString *const ADJLogFailKey;
FOUNDATION_EXPORT NSString *const ADJLogSdkPackageParamsKey;

FOUNDATION_EXPORT NSString *const ADJLogWhereKey;
FOUNDATION_EXPORT NSString *const ADJLogSubjectKey;
FOUNDATION_EXPORT NSString *const ADJLogWhyKey;
FOUNDATION_EXPORT NSString *const ADJLogExpectedKey;
FOUNDATION_EXPORT NSString *const ADJLogActualKey;
FOUNDATION_EXPORT NSString *const ADJLogValueKey;
FOUNDATION_EXPORT NSString *const ADJLogFromKey;
FOUNDATION_EXPORT NSString *const ADJLogValueNameKey;

FOUNDATION_EXPORT NSString *const ADJLogErrorKey;
FOUNDATION_EXPORT NSString *const ADJLogExceptionKey;

NS_ASSUME_NONNULL_END
