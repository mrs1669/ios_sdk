//
//  ADJGdprForgetController.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetController.h"

#import "ADJGdprForgetState.h"
#import "ADJGdprForgetTracker.h"
#import "ADJSingleThreadExecutor.h"

#pragma mark Private class
@implementation ADJGdprForgetPublisher @end

@interface ADJGdprForgetController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetStateStorage *storage;
@property (nullable, readwrite, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readwrite, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetPublisher *gdprForgetPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetState *gdprForgetState;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetTracker *gdprForgetTracker;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nullable, readwrite, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nullable, readwrite, strong, nonatomic) ADJGdprForgetPackageData *packageToSend;
@property (readwrite, assign, nonatomic) BOOL canPublish;

@end

@implementation ADJGdprForgetController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    gdprForgetStateStorage:(nonnull ADJGdprForgetStateStorage *)gdprForgetStateStorage
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    gdprForgetBackoffStrategy:(nonnull ADJBackoffStrategy *)gdprForgetBackoffStrategy
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"GdprForgetController"];
    _storage = gdprForgetStateStorage;
    _sdkPackageBuilderWeak = nil;
    _clockWeak = nil;

    ADJGdprForgetStateData *_Nonnull initialStateData =
        [gdprForgetStateStorage readOnlyStoredDataValue];

    _gdprForgetPublisher = [[ADJGdprForgetPublisher alloc]
                            initWithSubscriberProtocol:@protocol(ADJGdprForgetSubscriber)
                            controller:publisherController];
    
    _gdprForgetState = [[ADJGdprForgetState alloc]
                        initWithLoggerFactory:loggerFactory
                        initialStateData:initialStateData];
    
    _gdprForgetTracker = [[ADJGdprForgetTracker alloc]
                          initWithLoggerFactory:loggerFactory
                          gdprForgetBackoffStrategy:gdprForgetBackoffStrategy
                          startsAsking:[initialStateData isAsking]];
    
    _executor = [threadExecutorFactory
                 createSingleThreadExecutorWithLoggerFactory:loggerFactory
                 sourceLoggerName:self.logger.name];
    
    _sender = nil;
    
    _packageToSend = nil;
    
    return self;
}

- (void)
    ccSetDependenciesAtSdkInitWithSdkPackageBuilder:
        (nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(nonnull ADJClock *)clock
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
{
    self.sdkPackageBuilderWeak = sdkPackageBuilder;
    self.clockWeak = clock;
    
    self.sender = [sdkPackageSenderFactory
                   createSdkPackageSenderWithLoggerFactory:loggerFactory
                   sourceLoggerName:self.logger.name
                   threadExecutorFactory:threadExecutorFactory];
}

#pragma mark Public API
- (BOOL)isForgotten {
    return [[self.storage readOnlyStoredDataValue] isForgotten];
}

- (void)forgetDevice {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"forget device"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        ADJGdprForgetStateOutputData *_Nullable output =
            [strongSelf.gdprForgetState forgottenByClient];

        [strongSelf handleSideEffectsWithOutputData:output
                                         from:@"client forget device"];
    }];
}

#pragma mark - ADJSdkResponseCallbackSubscriber
- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (! [sdkResponseData isKindOfClass:[ADJGdprForgetResponseData class]]) {
        [self.logger debugDev:
         @"Cannot process response data with that is not an gdpr forget"
                expectedValue:NSStringFromClass([ADJGdprForgetResponseData class])
                  actualValue:NSStringFromClass([sdkResponseData class])
                    issueType:ADJIssueLogicError];
        return;
    }
    
    ADJGdprForgetResponseData *_Nonnull gdprForgetResponseData =
        (ADJGdprForgetResponseData *)sdkResponseData;
    
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"received gdpr forget response"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf gdprResponseWithData:gdprForgetResponseData];
    }];
}

#pragma mark - ADJAppStartSubscriber
- (void)ccAppStart {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"app start"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJGdprForgetStateOutputData *_Nullable output = [strongSelf.gdprForgetState appStart];

        [strongSelf handleSideEffectsWithOutputData:output
                                               from:@"app start"];
    }];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"allowed to publish notifications"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.canPublish = YES;

        ADJGdprForgetStateData *_Nonnull stateData = [strongSelf.storage readOnlyStoredDataValue];

        [strongSelf handlePublishWithStatus:[stateData status]
                                       from:@"allowed to publish"];
    }];
}

#pragma mark - ADJLifecycleSubscriber
- (void)ccDidForeground {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"foreground"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if ([strongSelf.gdprForgetTracker resumeSendingWhenAppWentToForeground]) {
            [strongSelf sendPackageFrom:@"DidForeground"];
        }
    }];
}

- (void)ccDidBackground {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"background"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.gdprForgetTracker pauseSendingWhenAppWentToBackground];
    }];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    // check if it has been opt out by the backend by any package
    if (! sdkResponseData.hasBeenOptOut) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"received opt out sdk response"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        ADJGdprForgetStateOutputData *_Nullable output =
            [strongSelf.gdprForgetState receivedOptOut];

        [strongSelf handleSideEffectsWithOutputData:output
                                               from:@"opt out"];
    }];
}

#pragma mark Internal Methods
- (void)gdprResponseWithData:(nonnull ADJGdprForgetResponseData *)gdprForgetResponseData {
    ADJDelayData *_Nullable delayData =
        [self.gdprForgetTracker
         delayTrackingWhenReceivedGdprForgetResponseWithData:gdprForgetResponseData];

    if (delayData != nil) {
        __typeof(self) __weak weakSelf = self;
        [self.executor scheduleInSequenceWithLogger:self.logger
                                               from:@"gdpr forget response delay"
                                     delayTimeMilli:delayData.delay
                                              block:^{
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (strongSelf == nil) { return; }

            [strongSelf.logger debugDev:@"Delay ended"
                             from:@"gdpr forget response delay"
                              key:@"delay from"
                            value:delayData.from];

            if ([strongSelf.gdprForgetTracker sendWhenDelayEnded]) {
                [strongSelf sendPackageFrom:@"Delay ended"];
            }
        }];
        return;
    }

    // nil delay implies accepted package

    // -> should not usee the same package again
    self.packageToSend  = nil;

    ADJGdprForgetStateOutputData *_Nullable output =
        [self.gdprForgetState receivedAcceptedGdprResponse];

    [self handleSideEffectsWithOutputData:output
                                     from:@"gdpr forget response from state"];
}

- (void)handleSideEffectsWithOutputData:(nullable ADJGdprForgetStateOutputData *)outputData
                                   from:(nonnull NSString *)from
{
    if (outputData == nil) { return; }

    [self handleChangedStateData:outputData.changedStateData];

    [self handlePublishWithStatus:outputData.status
                             from:from];

    [self handleTrackingCommand:outputData.startTracking from:from];
}

- (void)handleChangedStateData:(nullable ADJGdprForgetStateData *)changedStateData {
    if (changedStateData == nil) { return; }

    [self.storage updateWithNewDataValue:changedStateData];
}

- (void)handlePublishWithStatus:(nullable ADJGdprForgetStatus)status
                           from:(nonnull NSString *)from
{
    if (status == nil) { return; }
    if (! self.canPublish) { return; }

    [self.logger debugDev:@"Publishing gdpr forget state"
                     from:from];

    // the actual status value is not used by any of the subscribers
    //  so, it is not being published. If it that changes, add it
    [self.gdprForgetPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJGdprForgetSubscriber> _Nonnull subscriber)
     {
        [subscriber didGdprForget];
    }];
}

- (void)handleTrackingCommand:(BOOL)startTracking
                         from:(nonnull NSString *)from
{
    if (! startTracking) { return; }

    if ([self.gdprForgetTracker sendWhenStartTracking]) {
        [self sendPackageFrom:from];
    }
}

- (void)sendPackageFrom:(nonnull NSString *)from {
    if (self.packageToSend == nil) {
        ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
        if (sdkPackageBuilder == nil) {
            [self.logger debugDev:
                @"Cannot send gdpr forget without a reference to package builder"
                        issueType:ADJIssueWeakReference];
            return;
        }

        self.packageToSend = [sdkPackageBuilder buildGdprForgetPackage];
    }

    [self.logger debugDev:@"To send sdk package"
                     from:from
                      key:@"package"
                    value:[self.packageToSend generateShortDescription].stringValue];

    ADJStringMapBuilder *_Nonnull sendingParameters = [self generateSendingParameters];

    [self.sender sendSdkPackageWithData:self.packageToSend
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)generateSendingParameters {
    ADJStringMapBuilder *_Nonnull sendingParameters =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    [ADJSdkPackageBuilder
     injectAttemptsWithParametersBuilder:sendingParameters
     attempts:self.gdprForgetTracker.retriesSinceLastSuccessSend.countValue];

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot inject sentAt without a reference to clock"
                    issueType:ADJIssueWeakReference];

        return sendingParameters;
    }

    ADJResult<ADJTimestampMilli *> *_Nonnull nowResult = [clock nonMonotonicNowTimestamp];
    if (nowResult.fail != nil) {
        [self.logger debugDev:@"Invalid now timestamp when injecting sent at"
                   resultFail:nowResult.fail
                    issueType:ADJIssueExternalApi];
    } else {
        [ADJSdkPackageBuilder
         injectSentAtWithParametersBuilder:sendingParameters
         sentAtTimestamp:nowResult.value];

    }
    return sendingParameters;
}

@end
