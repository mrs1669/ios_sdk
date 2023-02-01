//
//  ADJStorageRoot.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTeardownFinalizer.h"
#import "ADJLoggerFactory.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJKeychainStorage.h"
#import "ADJSQLiteController.h"
#import "ADJClientActionStorage.h"
#import "ADJDeviceIdsStorage.h"
#import "ADJEventStateStorage.h"
#import "ADJPushTokenStateStorage.h"
#import "ADJEventDeduplicationStorage.h"
#import "ADJGlobalCallbackParametersStorage.h"
#import "ADJGlobalPartnerParametersStorage.h"
#import "ADJAttributionStateStorage.h"
#import "ADJAsaAttributionStateStorage.h"
#import "ADJLogQueueStorage.h"
#import "ADJGdprForgetStateStorage.h"
#import "ADJMainQueueStorage.h"
#import "ADJSdkActiveStateStorage.h"
#import "ADJMeasurementSessionStateStorage.h"

@interface ADJStorageRoot : NSObject<ADJTeardownFinalizer>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    instanceId:(nonnull ADJInstanceIdData *)instanceId
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJKeychainStorage *keychainStorage;
@property (nonnull, readonly, strong, nonatomic) ADJSQLiteController *sqliteController;

@property (nonnull, readonly, strong, nonatomic) ADJAttributionStateStorage *attributionStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionStateStorage *asaAttributionStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJClientActionStorage *clientActionStorage;
@property (nonnull, readonly, strong, nonatomic) ADJDeviceIdsStorage *deviceIdsStorage;
@property (nonnull, readonly, strong, nonatomic) ADJPushTokenStateStorage *pushTokenStorage;
@property (nonnull, readonly, strong, nonatomic) ADJEventStateStorage *eventStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJEventDeduplicationStorage *eventDeduplicationStorage;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalCallbackParametersStorage *globalCallbackParametersStorage;
@property (nonnull, readonly, strong, nonatomic) ADJGlobalPartnerParametersStorage *globalPartnerParametersStorage;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetStateStorage *gdprForgetStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJLogQueueStorage *logQueueStorage;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStorage *mainQueueStorage;
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveStateStorage *sdkActiveStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionStateStorage *measurementSessionStateStorage;

// public api
- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock;

@end

