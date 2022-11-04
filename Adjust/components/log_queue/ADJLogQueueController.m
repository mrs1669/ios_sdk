//
//  ADJLogQueueController.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogQueueController.h"

#import "ADJLogQueueStateAndTracker.h"
#import "ADJSdkPackageBuilder.h"

#pragma mark Fields
@interface ADJLogQueueController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJLogQueueStorage *storageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic) ADJLogQueueStateAndTracker *logQueueStateAndTracker;

@end

@implementation ADJLogQueueController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                      storage:(nonnull ADJLogQueueStorage *)storage
                             threadController:(nonnull ADJThreadController *)threadController
                                        clock:(nonnull ADJClock *)clock
                              backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy
                      sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"LogQueueController"];
    _storageWeak = storage;
    _clockWeak = clock;

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];

    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceDescription:self.source
                                                         threadExecutorFactory:threadController];

    _logQueueStateAndTracker =
    [[ADJLogQueueStateAndTracker alloc] initWithLoggerFactory:loggerFactory
                                              backoffStrategy:backoffStrategy];

    return self;

}

#pragma mark Public API
- (void)addLogPackageDataToSendWithData:(nonnull ADJLogPackageData *)logPackageData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleLogPackageAddedToSendWithData:logPackageData];
    }];
}

#pragma mark - ADJSdkResponseCallbackSubscriber
- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResponseWithData:sdkResponseData];
    }];
}

- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleSdkInit];
    }];
}

#pragma mark - ADJPausingSubscriber
- (void)didResumeSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResumeSending];
    }];
}

- (void)didPauseSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.logQueueStateAndTracker pauseSending];
    }];
}

#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithSdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
                                   pausingPublisher:(nonnull ADJPausingPublisher *)pausingPublisher {
    [sdkInitPublisher addSubscriber:self];
    [pausingPublisher addSubscriber:self];
}

#pragma mark Internal Methods
- (void)handleLogPackageAddedToSendWithData:(nonnull ADJLogPackageData *)logPackageDataToAdd {
    ADJLogQueueStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot add log package to send"
         " without a reference to the storage"];
        return;
    }

    [storage enqueueElementToLast:logPackageDataToAdd sqliteStorageAction:nil];

    ADJLogPackageData *_Nullable packageAtFront = [storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.logQueueStateAndTracker sendWhenLogPackageAddedWithData:logPackageDataToAdd
                                                packageQueueCount:[storage count]
                                                hasPackageAtFront:packageAtFront != nil];
    if (sendPackageAtFront) {
        NSString *_Nonnull source =
        [NSString stringWithFormat:@"%@ added",
         [logPackageDataToAdd generateShortDescription]];

        [self sendPackageWithData:packageAtFront
                          storage:storage
                           source:source];
    }
}

- (void)handleSdkInit {
    ADJLogQueueStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot handle sdk init"
         " without a reference to the storage"];
        return;
    }

    ADJLogPackageData *_Nullable packageAtFront = [storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.logQueueStateAndTracker sendWhenSdkInitWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                          storage:storage
                           source:@"sdk init"];
    }
}

- (void)handleResumeSending {
    ADJLogQueueStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot handle resuming sending"
         " without a reference to the storage"];
        return;
    }

    ADJLogPackageData *_Nullable packageAtFront = [storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.logQueueStateAndTracker
     sendWhenResumeSendingWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                          storage:storage
                           source:@"resume sending"];
    }
}

- (void)handleResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    ADJLogQueueStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot handle response"
         " without a reference to the storage"];
        return;
    }

    ADJQueueResponseProcessingData *_Nonnull responseProcessingData =
    [self.logQueueStateAndTracker processReceivedSdkResponseWithData:sdkResponseData];

    if (responseProcessingData.removePackageAtFront) {
        [self removePackageAtFrontWithStorage:storage];
    }

    if (responseProcessingData.delayData != nil) {
        [self delaySendWithData:responseProcessingData.delayData];
        return;
    }

    ADJLogPackageData *_Nullable packageAtFront = [storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.logQueueStateAndTracker
     sendAfterProcessingSdkResponseWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                          storage:storage
                           source:@"handle response"];
    }
}

- (void)removePackageAtFrontWithStorage:(nonnull ADJLogQueueStorage *)storage {
    ADJLogPackageData *_Nullable removedSdkPackage = [storage removeElementAtFront];

    if (removedSdkPackage == nil) {
        [self.logger error:@"Should not be empty when removing package at front"];
    } else {
        [self.logger debug:@"Package at front removed"];
    }
}

- (void)delaySendWithData:(nonnull ADJDelayData *)delayData {
    __typeof(self) __weak weakSelf = self;
    [self.executor
     scheduleInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleDelayEndWithSource:delayData.source];
    }
     delayTimeMilli:delayData.delay];
}

- (void)handleDelayEndWithSource:(nonnull NSString *)source {
    [self.logger debug:@"Delay due to %@ ended", source];

    ADJLogQueueStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot handle delay end"
         " without a reference to the storage"];
        return;
    }

    ADJLogPackageData *_Nullable packageAtFront = [storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.logQueueStateAndTracker
     sendWhenDelayEndedWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                          storage:storage
                           source:@"handle delay end"];
    }
}

- (void)sendPackageWithData:(nullable id<ADJSdkPackageData>)packageToSend
                    storage:(nonnull ADJLogQueueStorage *)storage
                     source:(nonnull NSString *)source {
    if (packageToSend == nil) {
        [self.logger error:@"Cannot send package from %@ when it is nil", source];
        return;
    }

    [self.logger debug:@"To send sdk package %@ from %@",
     [packageToSend generateShortDescription],
     source];

    ADJStringMapBuilder *_Nonnull sendingParameters =
    [self generateSendingParametersWithStorage:storage];

    [self.sender sendSdkPackageWithData:packageToSend
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)generateSendingParametersWithStorage:
(nonnull ADJLogQueueStorage *)storage {
    ADJStringMapBuilder *_Nonnull sendingParameters =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock != nil) {
        [ADJSdkPackageBuilder
         injectSentAtWithParametersBuilder:sendingParameters
         sentAtTimestamp:[clock nonMonotonicNowTimestampMilliWithLogger:self.logger]];
    } else {
        [self.logger error:@"Cannot inject sent at without a reference to clock"];
    }

    [ADJSdkPackageBuilder
     injectAttemptsWithParametersBuilder:sendingParameters
     attempts:[self.logQueueStateAndTracker retriesSinceLastSuccessSend]];

    ADJNonNegativeInt *_Nonnull currentQueueSize = [storage count];

    if (currentQueueSize.uIntegerValue > 0) {
        ADJNonNegativeInt *_Nonnull remaingQueueSize =
        [[ADJNonNegativeInt alloc] initWithUIntegerValue:
         currentQueueSize.uIntegerValue - 1];

        [ADJSdkPackageBuilder
         injectRemainingQueuSizeWithParametersBuilder:sendingParameters
         remainingQueueSize:remaingQueueSize];
    } else {
        [self.logger error:@"Cannot inject remaining queue sizy"
         " when its empty"];
    }

    return sendingParameters;
}

@end

