//
//  ADJSdkConfigData.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkConfigDataBuilder.h"

@interface ADJSdkConfigData : NSObject
// instantiation
- (nonnull instancetype)initWithDefaultValues;

- (nonnull instancetype)initWithBuilderData:
    (nonnull ADJSdkConfigDataBuilder *)sdkConfigDataBuilder
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
@property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *sessionDeviceIdsConfigData;
@property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *asaAttributionConfigData;
@property (nonnull, readonly, strong, nonatomic)
    ADJBackoffStrategy *attributionBackoffStrategy;
@property (nonnull, readonly, strong, nonatomic)
    ADJBackoffStrategy *gdprForgetBackoffStrategy;
@property (nonnull, readonly, strong, nonatomic)
    ADJBackoffStrategy *mainQueueBackoffStrategy;
@property (nullable, readonly, strong, nonatomic)
    id<ADJClientReturnExecutor> clientReturnExecutorOverwrite;
@property (nonnull, readonly, strong, nonatomic)
    ADJTimeLengthMilli *minMeasurementSessionIntervalMilli;
@property (nullable, readonly, strong, nonatomic)
    ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerStartMilli;
@property (nonnull, readonly, strong, nonatomic)
    ADJTimeLengthMilli *foregroundTimerIntervalMilli;
@property (readonly, assign, nonatomic) BOOL assumeSandboxEnvironmentForLogging;
@property (readonly, assign, nonatomic) BOOL doNotReadCurrentLifecycleStatus;
@property (readonly, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;

@end
