//
//  ADJStorageRootController.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJStorageRootController.h"
#import "ADJSingleThreadExecutor.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJKeychainStorage *keychainStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJSQLiteController *sqliteController;

 @property (nonnull, readonly, strong, nonatomic)ADJAttributionStateStorage *attributionStateStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJAsaAttributionStateStorage *asaAttributionStateStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJClientActionStorage *clientActionStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJDeviceIdsStorage *deviceIdsStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJEventStateStorage *eventStateStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJEventDeduplicationStorage *eventDeduplicationStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJGlobalCallbackParametersStorage *globalCallbackParametersStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJGdprForgetStateStorage *gdprForgetStateStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJGlobalPartnerParametersStorage *globalPartnerParametersStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJLogQueueStorage *logQueueStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJMainQueueStorage *mainQueueStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkActiveStateStorage *sdkActiveStateStorage;
 @property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionStateStorage *measurementSessionStateStorage;
 */
@interface ADJStorageRootController ()

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *storageExecutor;
//@property (nonnull, readonly, strong, nonatomic) ADJV4FilesController *v4FilesController;
@end

@implementation ADJStorageRootController
#pragma mark Instantiation
#define buildAndInjectStorage(varName, classType)       \
_ ## varName = [[classType alloc]                   \
initWithLoggerFactory:loggerFactory             \
storageExecutor:self.storageExecutor            \
sqliteController:self.sqliteController];        \
[self.sqliteController addSqlStorage:self.varName]  \

- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory {

    self = [super init];

    _storageExecutor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                        sourceDescription:@"storageExecutor"];

    _keychainStorage = [[ADJKeychainStorage alloc] initWithLoggerFactory:loggerFactory];

    _sqliteController = [[ADJSQLiteController alloc]
                         initWithLoggerFactory:loggerFactory];
    //v4FilesController:self.v4FilesController
    //systemAppDataController:self.systemAppDataController];

    buildAndInjectStorage(attributionStateStorage, ADJAttributionStateStorage);
    //    buildAndInjectStorage(asaAttributionStateStorage, ADJAsaAttributionStateStorage);
    buildAndInjectStorage(clientActionStorage, ADJClientActionStorage);
    buildAndInjectStorage(deviceIdsStorage, ADJDeviceIdsStorage);
    buildAndInjectStorage(eventStateStorage, ADJEventStateStorage);
    buildAndInjectStorage(eventDeduplicationStorage, ADJEventDeduplicationStorage);
    buildAndInjectStorage(gdprForgetStateStorage, ADJGdprForgetStateStorage);
    buildAndInjectStorage(globalCallbackParametersStorage, ADJGlobalCallbackParametersStorage);
    buildAndInjectStorage(globalPartnerParametersStorage, ADJGlobalPartnerParametersStorage);
    buildAndInjectStorage(logQueueStorage, ADJLogQueueStorage);
    buildAndInjectStorage(mainQueueStorage, ADJMainQueueStorage);
    buildAndInjectStorage(sdkActiveStateStorage, ADJSdkActiveStateStorage);
    buildAndInjectStorage(measurementSessionStateStorage, ADJMeasurementSessionStateStorage);

    [self.sqliteController readAllIntoMemorySync];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock {
    __typeof(self) __weak weakSelf = self;
    BOOL canExecuteTask = [self.storageExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.sqliteController.sqliteDb close];

        if (closeStorageBlock != nil) {
            closeStorageBlock();
        }

        // prevent any other storage task from executing
        [strongSelf.storageExecutor finalizeAtTeardown];
    }];

    if (! canExecuteTask && closeStorageBlock != nil) {
        closeStorageBlock();
    }
}

#pragma mark - ADJTeardownFinalizer

- (void)finalizeAtTeardown {
    [self finalizeAtTeardownWithCloseStorageBlock:nil];
}

@end
