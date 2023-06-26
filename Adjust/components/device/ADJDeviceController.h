//
//  ADJDeviceController.h
//  Adjust
//
//  Created by Pedro S. on 16.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJClock.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJDeviceIdsStorage.h"
#import "ADJKeychainStorage.h"
#import "ADJExternalConfigData.h"
#import "ADJNonEmptyString.h"
#import "ADJDeviceInfoData.h"
#import "ADJSessionDeviceIdsData.h"

@interface ADJDeviceController : ADJCommonBase<
    // subscriptions
    ADJLifecycleSubscriber
>
@property (nonnull, readonly, strong, nonatomic) ADJDeviceInfoData *deviceInfoData;

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    clock:(nonnull ADJClock *)clock
    deviceIdsStorage:(nonnull ADJDeviceIdsStorage *)deviceIdsStorage
    keychainStorage:(nonnull ADJKeychainStorage *)keychainStorage
    deviceIdsConfigData:(nonnull ADJExternalConfigData *)deviceIdsConfigData;

// public api
- (nullable ADJNonEmptyString *)keychainUuid;
- (nullable ADJNonEmptyString *)nonKeychainUuid;
- (nonnull ADJResult<ADJSessionDeviceIdsData *> *)getSessionDeviceIdsSync;

@end


