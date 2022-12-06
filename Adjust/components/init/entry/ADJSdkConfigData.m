//
//  ADJSdkConfigData.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkConfigData.h"

#pragma mark Fields
#pragma mark - Public properties
/*
 @property (nonnull, readonly, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
 @property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *sessionDeviceIdsConfigData;
 @property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *asaAttributionConfigData;
 @property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *attributionBackoffStrategy;
 @property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *gdprForgetBackoffStrategy;
 @property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *mainQueueBackoffStrategy;
 @property (nullable, readonly, strong, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutorOverwrite;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *minMeasurementSessionIntervalMilli;
 @property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerStartMilli;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerIntervalMilli;
 @property (readonly, assign, nonatomic) BOOL assumeSandboxEnvironmentForLogging;
 @property (readonly, assign, nonatomic) BOOL assumeDevLogs;
 @property (readonly, assign, nonatomic) BOOL doNotReadCurrentLifecycleStatus;
 @property (readonly, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;
 */

@implementation ADJSdkConfigData
#pragma mark Instantiation
- (nonnull instancetype)initWithDefaultValues {
    return [self initWithBuilderData:
            [[ADJSdkConfigDataBuilder alloc] initWithDefaultValues]];
}

- (nonnull instancetype)initWithBuilderData:(nonnull ADJSdkConfigDataBuilder *)sdkConfigDataBuilder {
    self = [super init];
    
    _networkEndpointData = sdkConfigDataBuilder.networkEndpointData;
    _sessionDeviceIdsConfigData = sdkConfigDataBuilder.sessionDeviceIdsConfigData;
    _asaAttributionConfigData = sdkConfigDataBuilder.asaAttributionConfigData;
    _attributionBackoffStrategy = sdkConfigDataBuilder.attributionBackoffStrategy;
    _gdprForgetBackoffStrategy = sdkConfigDataBuilder.gdprForgetBackoffStrategy;
    _mainQueueBackoffStrategy = sdkConfigDataBuilder.mainQueueBackoffStrategy;
    _clientReturnExecutorOverwrite = sdkConfigDataBuilder.clientReturnExecutorOverwrite;
    _minMeasurementSessionIntervalMilli = sdkConfigDataBuilder.minMeasurementSessionIntervalMilli;
    _overwriteFirstMeasurementSessionIntervalMilli = sdkConfigDataBuilder.overwriteFirstSdkSessionInterval;
    _foregroundTimerStartMilli = sdkConfigDataBuilder.foregroundTimerStartMilli;
    _foregroundTimerIntervalMilli = sdkConfigDataBuilder.foregroundTimerIntervalMilli;
    _assumeSandboxEnvironmentForLogging = sdkConfigDataBuilder.assumeSandboxEnvironmentForLogging;
    _assumeDevLogs = sdkConfigDataBuilder.assumeDevLogs;
    _doNotReadCurrentLifecycleStatus = sdkConfigDataBuilder.doNotReadCurrentLifecycleStatus;
    _doNotInitiateAttributionFromSdk = sdkConfigDataBuilder.doNotInitiateAttributionFromSdk;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
