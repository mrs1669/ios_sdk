//
//  ADJConstants.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJConstants.h"

double const ADJSecondToMilliDouble = 1000.0;
NSUInteger const ADJMilliToMicro = 1000;
NSUInteger const ADJMilliToNano = 1000000;

NSUInteger const ADJOneSecondMilli = 1000;
NSUInteger const ADJTenSecondsMilli = ADJOneSecondMilli * 10;
NSUInteger const ADJOneMinuteMilli = ADJOneSecondMilli * 60;
NSUInteger const ADJThirtyMinutesMilli = ADJOneMinuteMilli * 30;
NSUInteger const ADJOneHourMilli = ADJOneMinuteMilli * 60;

NSString *const ADJAdjustSubSystem = @"com.adjust.sdk";
NSString *const ADJAdjustCategory = @"Adjust";

NSString *const ADJAppAdjustUrl = @"https://app.adjust.com";
NSString *const ADJGdprAdjustUrl = @"https://gdpr.adjust.com";
NSString *const ADJSubscriptionAdjustUrl = @"https://subscription.adjust.com";

NSUInteger const ADJInitialHashCode = 17;
NSUInteger const ADJHashCodeMultiplier = 37;

NSUInteger const ADJDefaultMaxCapacityEventDeduplication = 10;

NSString *const ADJIdForAdvertisersZeros = @"00000000-0000-0000-0000-000000000000";

// IoData metadata
NSString *const ADJMetadataVersionKey = @"METADATA_VERSION";
NSString *const ADJMetadataVersionValue = @"5.0.0";
NSString *const ADJMetadataIoDataTypeKey = @"METADATA_IO_DATA_TYPE";
NSString *const ADJMetadataMapName = @"0_METADATA_MAP_TYPE";
NSString *const ADJPropertiesMapName = @"1_PROPERTIES_MAP_TYPE";

// default starting states
const BOOL ADJIsSdkPausedWhenStarting = YES;
const BOOL ADJIsSdkInForegroundWhenStarting = NO;
const BOOL ADJIsSdkActiveWhenStarting = YES;
const BOOL ADJIsSdkForgottenWhenStarting = NO;
const BOOL ADJIsSdkOfflineWhenStarting = NO;
const BOOL ADJIsNetworkReachableWhenStarting = YES;

// logging
NSString *const ADJLogMessageKey = @"message";
NSString *const ADJLogLevelKey = @"level";
NSString *const ADJLogIssueKey = @"issue";
NSString *const ADJLogParamsKey = @"params";
NSString *const ADJLogSourceKey = @"source";
NSString *const ADJLogCallerThreadIdKey = @"callerId";
NSString *const ADJLogRunningThreadIdKey = @"runningId";
NSString *const ADJLogCallerDescriptionKey = @"callerDescription";
NSString *const ADJLogInstanceIdKey = @"instanceId";
NSString *const ADJLogIsPreSdkInitKey = @"isPreSdkInit";
NSString *const ADJLogFailKey = @"fail";
NSString *const ADJLogSdkPackageParamsKey = @"sdkPackage_params";

NSString *const ADJLogWhereKey = @"where";
NSString *const ADJLogSubjectKey = @"subject";
NSString *const ADJLogWhyKey = @"why";
NSString *const ADJLogExpectedKey = @"expected";
NSString *const ADJLogActualKey = @"actual";
NSString *const ADJLogValueKey = @"value";
NSString *const ADJLogFromKey = @"from";
NSString *const ADJLogValueNameKey = @"value_name";

NSString *const ADJLogErrorKey = @"error";
NSString *const ADJLogExceptionKey = @"exception";
