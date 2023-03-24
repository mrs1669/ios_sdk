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
#import "ADJValueWO.h"

#pragma mark Private class
@implementation ADJGdprForgetPublisher @end

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJGdprForgetPublisher *gdprForgetPublisher;
 */

@interface ADJGdprForgetController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJGdprForgetStateStorage *gdprForgetStateStorageWeak;
@property (nullable, readwrite, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readwrite, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetState *gdprForgetState;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetTracker *gdprForgetTracker;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nullable, readwrite, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nullable, readwrite, strong, nonatomic) ADJGdprForgetPackageData *previousAttemptedPackage;

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
    _gdprForgetStateStorageWeak = gdprForgetStateStorage;
    _sdkPackageBuilderWeak = nil;
    _clockWeak = nil;
    
    _gdprForgetPublisher = [[ADJGdprForgetPublisher alloc]
                            initWithSubscriberProtocol:@protocol(ADJGdprForgetSubscriber)
                            controller:publisherController];
    
    _gdprForgetState = [[ADJGdprForgetState alloc] initWithLoggerFactory:loggerFactory];
    
    _gdprForgetTracker = [[ADJGdprForgetTracker alloc] initWithLoggerFactory:loggerFactory
                                                   gdprForgetBackoffStrategy:gdprForgetBackoffStrategy];
    
    _executor = [threadExecutorFactory
                 createSingleThreadExecutorWithLoggerFactory:loggerFactory
                 sourceLoggerName:self.logger.name];
    
    _sender = nil;
    
    _previousAttemptedPackage = nil;
    
    return self;
}

- (void)ccSetDependenciesAtSdkInitWithSdkPackageBuilder:
(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                                                  clock:(nonnull ADJClock *)clock
                                          loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                  threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                                sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory {
    self.sdkPackageBuilderWeak = sdkPackageBuilder;
    self.clockWeak = clock;
    
    self.sender = [sdkPackageSenderFactory
                   createSdkPackageSenderWithLoggerFactory:loggerFactory
                   sourceLoggerName:self.logger.name
                   threadExecutorFactory:threadExecutorFactory];
}

#pragma mark Public API
- (BOOL)isForgotten {
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage =
    self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:@"Cannot get isForgotten without a reference to storage"
                    issueType:ADJIssueWeakReference];
        
        return NO;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];
    
    return [currentGdprForgetStateData isForgotten];
}

- (void)forgetDevice {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"forget device"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf processForgetDevice];
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
        
        [strongSelf processGdprForgetResponseInStateWithData:gdprForgetResponseData];
        
        [strongSelf processGdprForgetResponseInTrackerWithData:gdprForgetResponseData];
    }];
}

#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk init"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf processSdkInit];
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
        
        [strongSelf.gdprForgetState canStartPublish];
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
        
        [strongSelf processForegroundInState];
        
        [strongSelf processForegroundInTracker];
    }];
}

- (void)ccDidBackground {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"background"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.gdprForgetState appWentToTheBackground];
        
        [strongSelf.gdprForgetTracker pauseTrackingWhenAppWentToBackground];
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
        
        [strongSelf processOptOut];
    }];
}

#pragma mark Internal Methods
- (void)processForgetDevice {
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage = self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:@"Cannot forget device without a reference to the storage"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];

    ADJValueWO<ADJGdprForgetStateData *> *_Nonnull changedGdprForgetStateDataWO =
    [[ADJValueWO alloc] init];

    ADJValueWO<NSString *> *_Nonnull gdprForgetStatusEventWO = [[ADJValueWO alloc] init];
    
    BOOL shouldStartTracking = [self.gdprForgetState  shouldStartTrackingWhenForgottenByClientWithCurrentStateData:currentGdprForgetStateData
                                                                                      changedGdprForgetStateDataWO:changedGdprForgetStateDataWO
                                                                                           gdprForgetStatusEventWO:gdprForgetStatusEventWO];
    
    [self handleStartingStateSideEffectsWithShouldStart:shouldStartTracking
                             changedGdprForgetStateData:[changedGdprForgetStateDataWO changedValue]
                                  gdprForgetStatusEvent:[gdprForgetStatusEventWO changedValue]
                                 gdprForgetStateStorage:gdprForgetStateStorage
                                      sourceDescription:@"forgetDevice"];
}

- (void)processGdprForgetResponseInStateWithData:(nonnull ADJGdprForgetResponseData *)gdprForgetResponseData {
    // state does not change when GdprForget was not processed by the backend
    if (! gdprForgetResponseData.processedByServer) {
        return;
    }
    
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage =
    self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:
         @"Cannot process gdpr forget response in state without a reference to the storage"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];
    ADJValueWO<ADJGdprForgetStateData *> *_Nonnull changedGdprForgetStateDataWO =
    [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull gdprForgetStatusEventWO = [[ADJValueWO alloc] init];
    
    BOOL shouldStopTracking =
    [self.gdprForgetState
     shouldStopTrackingWhenReceivedProcessedGdprResponseWithCurrentStateData:
         currentGdprForgetStateData
     changedGdprForgetStateDataWO:changedGdprForgetStateDataWO
     gdprForgetStatusEventWO:gdprForgetStatusEventWO];
    
    [self
     handleStoppingStateSideEffectsWithShouldStop:shouldStopTracking
     changedGdprForgetStateData:[changedGdprForgetStateDataWO changedValue]
     gdprForgetStatusEvent:[gdprForgetStatusEventWO changedValue]
     gdprForgetStateStorage:gdprForgetStateStorage];
}

- (void)processGdprForgetResponseInTrackerWithData:
    (nonnull ADJGdprForgetResponseData *)gdprForgetResponseData
{
    ADJDelayData *_Nullable delayData =
    [self.gdprForgetTracker
     delayTrackingWhenReceivedGdprForgetResponseWithData:gdprForgetResponseData];
    
    if (delayData == nil) {
        // remove previous attempted package cache,
        //  since it won't be delayed to send the same one
        self.previousAttemptedPackage = nil;
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [self.executor scheduleInSequenceWithLogger:self.logger
                                           from:@"send gdpr forget"
                                 delayTimeMilli:delayData.delay
                                          block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        BOOL sendGdprForget = [strongSelf.gdprForgetTracker sendWhenDelayEnded];
        
        if (sendGdprForget) {
            [strongSelf sendGdprForgetWithSourceDescription:@"DelayEnd"];
        }
    }];
}

- (void)processSdkInit {
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage =
    self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:@"Cannot handle sdk init without a reference to the storage"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];
    ADJValueWO<NSString *> *_Nonnull gdprForgetStatusEventWO = [[ADJValueWO alloc] init];
    
    BOOL shouldStartTracking =
    [self.gdprForgetState
     shouldStartTrackingWhenSdkInitWithCurrentStateData:currentGdprForgetStateData
     gdprForgetStatusEventWO:gdprForgetStatusEventWO];
    
    [self handleStartingStateSideEffectsWithShouldStart:shouldStartTracking
                             changedGdprForgetStateData:nil
                                  gdprForgetStatusEvent:[gdprForgetStatusEventWO changedValue]
                                 gdprForgetStateStorage:gdprForgetStateStorage
                                      sourceDescription:@"SdkInit"];
}

- (void)processForegroundInState {
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage =
    self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:@"Cannot foreground without a reference to the storage"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];
    
    BOOL shouldStartTracking =
    [self.gdprForgetState
     shouldStartTrackingWhenAppWentToTheForegroundWithCurrentStateData:
         currentGdprForgetStateData];
    
    [self handleStartingStateSideEffectsWithShouldStart:shouldStartTracking
                             changedGdprForgetStateData:nil
                                  gdprForgetStatusEvent:nil
                                 gdprForgetStateStorage:gdprForgetStateStorage
                                      sourceDescription:@"Foreground"];
}

- (void)processForegroundInTracker {
    BOOL sendGdprForget = [self.gdprForgetTracker sendWhenAppWentToForeground];
    
    if (sendGdprForget) {
        [self sendGdprForgetWithSourceDescription:@"Foreground"];
    }
}

- (void)processOptOut {
    ADJGdprForgetStateStorage *_Nullable gdprForgetStateStorage =
    self.gdprForgetStateStorageWeak;
    if (gdprForgetStateStorage == nil) {
        [self.logger debugDev:@"Cannot handle sdk init without a reference to the storage"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetStateData *_Nonnull currentGdprForgetStateData =
    [gdprForgetStateStorage readOnlyStoredDataValue];
    ADJValueWO<ADJGdprForgetStateData *> *_Nonnull changedGdprForgetStateDataWO =
    [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull gdprForgetStatusEventWO = [[ADJValueWO alloc] init];
    
    BOOL shouldStopTracking =
    [self.gdprForgetState
     shouldStopTrackingWhenReceivedOptOutWithCurrentStateData:currentGdprForgetStateData
     changedGdprForgetStateDataWO:changedGdprForgetStateDataWO
     gdprForgetStatusEventWO:gdprForgetStatusEventWO];
    
    [self
     handleStoppingStateSideEffectsWithShouldStop:shouldStopTracking
     changedGdprForgetStateData:[changedGdprForgetStateDataWO changedValue]
     gdprForgetStatusEvent:[gdprForgetStatusEventWO changedValue]
     gdprForgetStateStorage:gdprForgetStateStorage];
}

- (void)handleStartingStateSideEffectsWithShouldStart:(BOOL)shouldStartTracking
                           changedGdprForgetStateData:(nullable ADJGdprForgetStateData *)changedGdprForgetStateData
                                gdprForgetStatusEvent:(nullable NSString *)gdprForgetStatusEvent
                               gdprForgetStateStorage:(nullable ADJGdprForgetStateStorage *)gdprForgetStateStorage
                                    sourceDescription:(nonnull NSString *)sourceDescription {
    if (shouldStartTracking) {
        BOOL sendGdprForget = [self.gdprForgetTracker sendWhenStartTracking];
        
        if (sendGdprForget) {
            [self sendGdprForgetWithSourceDescription:sourceDescription];
        }
    }
    
    [self handleStateSideEffectsWithChangedGdprForgetStateData:changedGdprForgetStateData
                                         gdprForgetStatusEvent:gdprForgetStatusEvent
                                        gdprForgetStateStorage:gdprForgetStateStorage];
}

- (void)handleStoppingStateSideEffectsWithShouldStop:(BOOL)shouldStopTracking
                          changedGdprForgetStateData:(nullable ADJGdprForgetStateData *)changedGdprForgetStateData
                               gdprForgetStatusEvent:(nullable NSString *)gdprForgetStatusEvent
                              gdprForgetStateStorage:(nullable ADJGdprForgetStateStorage *)gdprForgetStateStorage {
    if (shouldStopTracking) {
        [self.gdprForgetTracker stopTracking];
    }
    
    [self handleStateSideEffectsWithChangedGdprForgetStateData:changedGdprForgetStateData
                                         gdprForgetStatusEvent:gdprForgetStatusEvent
                                        gdprForgetStateStorage:gdprForgetStateStorage];
}

- (void)handleStateSideEffectsWithChangedGdprForgetStateData:(nullable ADJGdprForgetStateData *)changedGdprForgetStateData
                                       gdprForgetStatusEvent:(nullable NSString *)gdprForgetStatusEvent
                                      gdprForgetStateStorage:(nullable ADJGdprForgetStateStorage *)gdprForgetStateStorage {
    if (changedGdprForgetStateData != nil) {
        [gdprForgetStateStorage updateWithNewDataValue:changedGdprForgetStateData];
    }
    
    if (gdprForgetStatusEvent != nil) {
        [self.gdprForgetPublisher notifySubscribersWithSubscriberBlock:
         ^(id<ADJGdprForgetSubscriber> _Nonnull subscriber)
         {
            [subscriber didGdprForget];
        }];
    }
}

- (void)sendGdprForgetWithSourceDescription:(nonnull NSString *)sourceDescription {
    if (self.previousAttemptedPackage == nil) {
        ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
        
        if (sdkPackageBuilder == nil) {
            [self.logger debugDev:@"Cannot forget device without a reference to package builder"
                        issueType:ADJIssueWeakReference];
            return;
        }
        
        self.previousAttemptedPackage = [sdkPackageBuilder buildGdprForgetPackage];
    }
    
    if (self.sender == nil) {
        [self.logger debugDev:@"Cannot send package without before sender dependency at sdk init"
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJGdprForgetPackageData *_Nonnull gdprForgetPackageData = self.previousAttemptedPackage;
    
    [self.logger debugDev:@"To send sdk package"
                     from:sourceDescription
                      key:@"package"
                    value:[gdprForgetPackageData generateShortDescription].stringValue];

    ADJStringMapBuilder *_Nonnull sendingParameters = [self generateSendingParameters];
    
    [self.sender sendSdkPackageWithData:gdprForgetPackageData
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
