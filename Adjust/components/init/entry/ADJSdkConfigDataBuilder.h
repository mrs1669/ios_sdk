//
//  ADJSdkConfigDataBuilder.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNetworkEndpointData.h"
#import "ADJExternalConfigData.h"
#import "ADJBackoffStrategy.h"
#import "ADJClientReturnExecutor.h"
#import "ADJTimeLengthMilli.h"

@interface ADJSdkConfigDataBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithDefaultValues NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readwrite, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
@property (nonnull, readwrite, strong, nonatomic) ADJExternalConfigData *sessionDeviceIdsConfigData;
@property (nonnull, readwrite, strong, nonatomic) ADJExternalConfigData *asaAttributionConfigData;
@property (nonnull, readwrite, strong, nonatomic)
    ADJBackoffStrategy *attributionBackoffStrategy;
@property (nonnull, readwrite, strong, nonatomic)
    ADJBackoffStrategy *gdprForgetBackoffStrategy;
@property (nonnull, readwrite, strong, nonatomic)
    ADJBackoffStrategy *mainQueueBackoffStrategy;
@property (nullable, readwrite, strong, nonatomic)
    id<ADJClientReturnExecutor> clientReturnExecutorOverwrite;
@property (nonnull, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *minMeasurementSessionIntervalMilli;
@property (nullable, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
@property (nonnull, readwrite, strong, nonatomic) ADJTimeLengthMilli *foregroundTimerStartMilli;
@property (nonnull, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *foregroundTimerIntervalMilli;
@property (readwrite, assign, nonatomic) BOOL assumeSandboxEnvironmentForLogging;
@property (readwrite, assign, nonatomic) BOOL doNotReadCurrentLifecycleStatus;
@property (readwrite, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;

@end
