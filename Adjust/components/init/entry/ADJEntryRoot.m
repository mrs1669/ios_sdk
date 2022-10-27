//
//  ADJEntryRoot.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEntryRoot.h"

#import "ADJAdjustInternal.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJLogController *logController;
 @property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
 @property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
 @property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *commonExecutor;
 @property (nonnull, readonly, strong, nonatomic) ADJLogger *adjustApiLogger;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkConfigData *sdkConfigData;

 // - built in client context
 @property (nullable, readonly, strong, nonatomic) ADJPreSdkInitRootController *preSdkInitRootController;
 @property (nullable, readonly, strong, nonatomic) ADJPostSdkInitRootController *postSdkInitRootController;
 */

@interface ADJEntryRoot ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJLogger *rootLogger;
@property (nullable, readwrite, strong, nonatomic) ADJPreSdkInitRootController *preSdkInitRootController;
@property (nullable, readwrite, strong, nonatomic)ADJPostSdkInitRootController *postSdkInitRootController;

@end

@implementation ADJEntryRoot
#pragma mark Instantiation
- (nonnull instancetype)initWithSdkConfigDataBuilder:(nullable ADJSdkConfigDataBuilder *)sdkConfigDataBuilder {
    self = [super init];

    if (sdkConfigDataBuilder != nil) {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithBuilderData:sdkConfigDataBuilder];
    } else {
        _sdkConfigData = [[ADJSdkConfigData alloc] initWithDefaultValues];
    }

    _logController = [[ADJLogController alloc] initWithInstanceId:nil
                                                    sdkConfigData:_sdkConfigData];

    _threadController = [[ADJThreadController alloc] initWithLoggerFactory:_logController];

    _clientExecutor =
    [_threadController createSingleThreadExecutorWithLoggerFactory:_logController
                                                 sourceDescription:@"clientExecutor"];

    _commonExecutor =
    [_threadController createSingleThreadExecutorWithLoggerFactory:_logController
                                                 sourceDescription:@"commonExecutor"];

    [_logController injectDependeciesWithCommonExecutor:_commonExecutor];

    _adjustApiLogger = [_logController createLoggerWithSource:@"Adjust"];

    _rootLogger = [_logController createLoggerWithSource:@"EntryRoot"];


    _preSdkInitRootController = nil;

    _postSdkInitRootController = nil;

    __typeof(self) __weak weakSelf = self;
    [_clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.preSdkInitRootController =
        [[ADJPreSdkInitRootController alloc] initWithLoggerFactory:strongSelf.logController
                                                         entryRoot:strongSelf];
    }];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
+ (void)executeBlockInClientContext:(nonnull void (^)(id<ADJClientAPI> _Nonnull adjustAPI, ADJLogger *_Nonnull apiLogger))blockInClientContext {
    ADJEntryRoot *_Nonnull root = [ADJAdjustInternal rootInstance];

    // TODO: (Gena) Why do we need ths check👇🏻? ('preSdkInitRootController' is created by ADJEntryRoot initializer)
    // no weak/strong self needed since it does not use self inside
    [root.clientExecutor executeInSequenceWithBlock:^{
        if (root.preSdkInitRootController == nil) {
            [root.adjustApiLogger error:
             @"Cannot execute in client context without pre sdk init controller"];
            return;
        }

        blockInClientContext(root.preSdkInitRootController, root.adjustApiLogger);
    }];
}

- (nonnull ADJPostSdkInitRootController *)ccCreatePostSdkInitRootControllerWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData
                                                                       preSdkInitRootController:(nonnull ADJPreSdkInitRootController *)preSdkInitRootController {
    self.postSdkInitRootController =
    [[ADJPostSdkInitRootController alloc] initWithLoggerFactory:self.logController
                                               clientConfigData:clientConfigData
                                                      entryRoot:self
                                       preSdkInitRootController:preSdkInitRootController];

    return self.postSdkInitRootController;
}

- (nonnull id<ADJClientReturnExecutor>)clientReturnExecutor {
    if (self.sdkConfigData.clientReturnExecutorOverwrite != nil) {
        return self.sdkConfigData.clientReturnExecutorOverwrite;
    }

    return self.threadController;
}

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock {
    __typeof(self) __weak weakSelf = self;
    BOOL canExecuteTask = [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        if (strongSelf.preSdkInitRootController != nil) {
            [strongSelf.preSdkInitRootController.storageRootController finalizeAtTeardownWithCloseStorageBlock:closeStorageBlock];
            [strongSelf.preSdkInitRootController.lifecycleController finalizeAtTeardown];
        }

        if (strongSelf.postSdkInitRootController != nil) {
            [strongSelf.postSdkInitRootController.reachabilityController finalizeAtTeardown];
        }

        [strongSelf.threadController finalizeAtTeardown];
    }];

    if (! canExecuteTask && closeStorageBlock != nil) {
        closeStorageBlock();
    }
}

#pragma mark - Subscriptions
- (void)ccSubscribeAndSetPostSdkInitDependenciesWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
                                             publishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher {
    [self.logController ccSubscribeToPublishersWithSdkInitPublisher:sdkInitPublisher
                                            publishingGatePublisher:publishingGatePublisher];
}

@end



