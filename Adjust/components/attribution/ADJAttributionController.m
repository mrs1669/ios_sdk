//
//  ADJAttributionController.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionController.h"

#import "ADJSingleThreadExecutor.h"
#import "ADJAttributionTracker.h"
#import "ADJAttributionState.h"

#pragma mark Private class
@implementation ADJAttributionPublisher @end

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic)ADJAttributionPublisher *attributionPublisher;
 */

@interface ADJAttributionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJAttributionStateStorage *attributionStateStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionTracker *attributionTracker;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionState *attributionState;

@end

@implementation ADJAttributionController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clock:(nonnull ADJClock *)clock
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    threadController:(nonnull ADJThreadController *)threadController
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"AttributionController"];
    _attributionStateStorageWeak = attributionStateStorage;
    _clockWeak = clock;
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    
    _attributionPublisher = [[ADJAttributionPublisher alloc]
                             initWithSubscriberProtocol:@protocol(ADJAttributionSubscriber)
                             controller:publisherController];
    
    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];
    
    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceDescription:self.source
                                                         threadExecutorFactory:threadController];
    
    _attributionTracker = [[ADJAttributionTracker alloc]
                           initWithLoggerFactory:loggerFactory
                           attributionBackoffStrategy:attributionBackoffStrategy];

    ADJNonNegativeInt *_Nullable firstSessionCount = [mainQueueController firstSessionCount];
    BOOL isFirstSessionInQueue = firstSessionCount != nil && firstSessionCount.uIntegerValue > 0;
    _attributionState = [[ADJAttributionState alloc]
                         initWithLoggerFactory:loggerFactory
                         doNotInitiateAttributionFromSdk:doNotInitiateAttributionFromSdk
                         isFirstSessionInQueue:isFirstSessionInQueue];
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkResponseCallbackSubscriber
- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (! [sdkResponseData isKindOfClass:[ADJAttributionResponseData class]]) {
        [self.logger debugDev:
         @"Cannot process response data with that is not an attribution"
                expectedValue:NSStringFromClass([ADJAttributionResponseData class])
                  actualValue:NSStringFromClass([sdkResponseData class])
                    issueType:ADJIssueLogicError];
        return;
    }
    
    ADJAttributionResponseData *_Nonnull attributionResponseData =
    (ADJAttributionResponseData *)sdkResponseData;
    
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf handleAttributionResponseInStateWithData:attributionResponseData];
        
        [strongSelf handleAttributionResponseInTrackerWithData:attributionResponseData];
    } source:@"received attribution response"];
}

- (void)handleAttributionResponseInStateWithData:(nonnull ADJAttributionResponseData *)attributionResponseData {
    if (attributionResponseData.shouldRetry) {
        [self.logger debugDev:@"Cannot change state without an accepted attribution response"];
        return;
    }
    
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleAttributionResponseInState"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    ADJValueWO<ADJAttributionStateData *> *_Nonnull changedAttributionStateDataWO =
    [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull attributionStatusEventWO = [[ADJValueWO alloc] init];
    
    BOOL stopAsking =
    [self.attributionState
     stopAskingWhenReceivedAcceptedAttributionResponseWithCurrentAttributionStateData:
         currentAttributionStateData
     attributionResponseData:attributionResponseData
     changedAttributionStateDataWO:changedAttributionStateDataWO
     attributionStatusEventWO:attributionStatusEventWO];
    
    [self handleSideEffectsWithStopAsking:stopAsking
              changedAttributionStateData:changedAttributionStateDataWO.changedValue
                   attributionStatusEvent:attributionStatusEventWO.changedValue
                                   source:@"handleAttributionResponseInState"];
}

- (void)handleAttributionResponseInTrackerWithData:(nonnull ADJAttributionResponseData *)attributionResponseData {
    ADJDelayData *_Nullable delayData =
    [self.attributionTracker
     delaySendingWhenReceivedAttributionResponseWithData:attributionResponseData];
    
    [self handleSideEffectsWithDelayData:delayData
                                  source:@"handleAttributionResponseInTracker"];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (sdkResponseData.shouldRetry) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        // handling SdkResponse before SessionResponse
        //  since asking from backend takes precedent from sdk
        [strongSelf handleAcceptedSdkResponseInStateWithData:sdkResponseData];
        
        [strongSelf handleAccepteSessionResponseInStateWithData:sdkResponseData];
    } source:@"received sdk response"];
}

- (void)handleAcceptedSdkResponseInStateWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleAcceptedSdkResponseInState"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    ADJValueWO<ADJAttributionStateData *> *_Nonnull changedAttributionStateDataWO =
    [[ADJValueWO alloc] init];
    ADJValueWO<ADJDelayData *> *_Nonnull delayDataWO = [[ADJValueWO alloc] init];
    
    NSString *_Nullable askingAttribution =
    [self.attributionState
     startAskingWhenReceivedAcceptedSdkResponseWithCurrentAttributionStateData:
         currentAttributionStateData
     sdkResponse:sdkResponseData
     changedAttributionStateDataWO:changedAttributionStateDataWO
     delayDataWO:delayDataWO];
    
    [self handleSideEffectsWithDelayData:delayDataWO.changedValue
                       askingAttribution:askingAttribution
             changedAttributionStateData:changedAttributionStateDataWO.changedValue
                                  source:@"handleAcceptedSdkResponseInState"];
}

- (void)handleAccepteSessionResponseInStateWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (! [sdkResponseData isKindOfClass:[ADJSessionResponseData class]]) {
        return;
    }
    
    ADJSessionResponseData *_Nonnull sessionResponseData =
    (ADJSessionResponseData *)sdkResponseData;
    
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleAccepteSessionResponseInState"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    ADJValueWO<ADJAttributionStateData *> *_Nonnull changedAttributionStateDataWO =
    [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull attributionStatusEventWO = [[ADJValueWO alloc] init];
    
    NSString *_Nullable askingAttribution =
    [self.attributionState
     startAskingWhenReceivedProcessedSessionResponseWithCurrentAttributionStateData:
         currentAttributionStateData
     sessionResponseData:sessionResponseData
     changedAttributionStateDataWO:changedAttributionStateDataWO
     attributionStatusEventWO:attributionStatusEventWO];
    
    [self handleSideEffectsWithAskingAttribution:askingAttribution
                     changedAttributionStateData:changedAttributionStateDataWO.changedValue
                          attributionStatusEvent:attributionStatusEventWO.changedValue
                                          source:@"handleAccepteSessionResponseInState"];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf handleAllowedToPublishNotifications];
    } source:@"allowed to publish notifications"];
}

- (void)handleAllowedToPublishNotifications {
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleAllowedToPublishNotifications"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    NSString *_Nonnull attributionStatusEvent =
    [self.attributionState
     statusEventAtGateOpenWithCurrentAttributionStateData:currentAttributionStateData];
    
    [self handleSideEffectsWithAttributionStatusEvent:attributionStatusEvent
                                               source:@"handleAllowedToPublishNotifications"];
}

#pragma mark - ADJMeasurementSessionStartSubscriber
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)MeasurementSessionStartStatus {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf handleMeasurementSessionStartWithStatus:MeasurementSessionStartStatus];
    } source:@"measurement session start"];
}

- (void)handleMeasurementSessionStartWithStatus:(nonnull NSString *)MeasurementSessionStartStatus {
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleMeasurementSessionStart"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    BOOL isFirstSession =
    [ADJMeasurementSessionStartStatusFirstSession isEqualToString:MeasurementSessionStartStatus];
    
    ADJValueWO<ADJAttributionStateData *> *_Nonnull changedAttributionStateDataWO =
    [[ADJValueWO alloc] init];
    
    NSString *_Nullable askingAttribution =
    [self.attributionState
     startAskingWhenSdkStartWithCurrentAttributionStateData:currentAttributionStateData
     isFirstStart:isFirstSession
     changedAttributionStateDataWO:changedAttributionStateDataWO];
    
    [self handleSideEffectsWithAskingAttribution:askingAttribution
                     changedAttributionStateData:changedAttributionStateDataWO.changedValue
                                          source:@"handleMeasurementSessionStart"];
}

#pragma mark - ADJPausingSubscriber
- (void)didResumeSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        BOOL sendAttribution = [strongSelf.attributionTracker sendWhenSdkResumingSending];
        
        if (sendAttribution) {
            [strongSelf sendAttributionWithSource:@"ResumeSending"];
        }
    } source:@"resume sending"];
}

- (void)didPauseSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf.attributionTracker pauseSending];
    } source:@"pause sending"];
}

#pragma mark Internal Methods
- (nullable ADJAttributionStateData *)currentAttributionStateDataWithSource:(nonnull NSString *)source {
    ADJAttributionStateStorage *_Nullable attributionStateStorage = self.attributionStateStorageWeak;
    if (attributionStateStorage == nil) {
        [self.logger debugDev:@"Cannot procces without a reference to storage"
                         from:source
                    issueType:ADJIssueWeakReference];
        return nil;
    }
    
    return [attributionStateStorage readOnlyStoredDataValue];
}

- (void)handleSideEffectsWithStopAsking:(BOOL)stopAsking
            changedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                 attributionStatusEvent:(nullable NSString *)attributionStatusEvent
                                 source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:nil
                       askingAttribution:nil
                              stopAsking:stopAsking
             changedAttributionStateData:changedAttributionStateData
                  attributionStatusEvent:attributionStatusEvent
                                  source:source];
}

- (void)handleSideEffectsWithDelayData:(nullable ADJDelayData *)delayData
                                source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:delayData
                       askingAttribution:nil
                              stopAsking:NO
             changedAttributionStateData:nil
                  attributionStatusEvent:nil
                                  source:source];
}

- (void)handleSideEffectsWithAttributionStatusEvent:(nullable NSString *)attributionStatusEvent
                                             source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:nil
                       askingAttribution:nil
                              stopAsking:NO
             changedAttributionStateData:nil
                  attributionStatusEvent:attributionStatusEvent
                                  source:source];
}

- (void)handleSideEffectsWithAskingAttribution:(nullable NSString *)askingAttribution
                   changedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                                        source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:nil
                       askingAttribution:askingAttribution
                              stopAsking:NO
             changedAttributionStateData:changedAttributionStateData
                  attributionStatusEvent:nil
                                  source:source];
}

- (void)handleSideEffectsWithDelayData:(nullable ADJDelayData *)delayData
                     askingAttribution:(nullable NSString *)askingAttribution
           changedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                                source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:delayData
                       askingAttribution:askingAttribution
                              stopAsking:NO
             changedAttributionStateData:changedAttributionStateData
                  attributionStatusEvent:nil
                                  source:source];
}

- (void)handleSideEffectsWithAskingAttribution:(nullable NSString *)askingAttribution
                   changedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                        attributionStatusEvent:(nullable NSString *)attributionStatusEvent
                                        source:(nonnull NSString *)source {
    [self handleSideEffectsWithDelayData:nil
                       askingAttribution:askingAttribution
                              stopAsking:NO
             changedAttributionStateData:changedAttributionStateData
                  attributionStatusEvent:attributionStatusEvent
                                  source:source];
}

- (void)handleSideEffectsWithDelayData:(nullable ADJDelayData *)delayData
                     askingAttribution:(nullable NSString *)askingAttribution
                            stopAsking:(BOOL)stopAsking
           changedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                attributionStatusEvent:(nullable NSString *)attributionStatusEvent
                                source:(nonnull NSString *)source {
    [self handleDelayWithData:delayData source:source];
    
    [self handleAskingAttributionWithString:askingAttribution
                                 stopAsking:stopAsking
                                     source:source];
    
    [self handleChangedAttributionStateData:changedAttributionStateData source:source];
    
    [self handleAttributionStatusEvent:attributionStatusEvent source:source];
}

- (void)handleDelayWithData:(nullable ADJDelayData *)delayData
                     source:(nonnull NSString *)source {
    if (delayData == nil) {
        return;
    }
    
    BOOL canDelay = [self.attributionTracker canDelay];
    if (! canDelay) {
        return;
    }
    
    __typeof(self) __weak weakSelf = self;
    [self.executor scheduleInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        [strongSelf handleDelayEndWithData:delayData source:source];
    }
                                delayTimeMilli:delayData.delay
                                        source:@"delay end"];
}

- (void)handleDelayEndWithData:(nonnull ADJDelayData *)delayData
                        source:(nonnull NSString *)source {
    [self.logger debugDev:@"Delay ended"
                     from:source
                      key:@"delayReason"
                    value:delayData.source];
    
    ADJAttributionStateData *_Nullable currentAttributionStateData =
    [self currentAttributionStateDataWithSource:@"handleDelayEnd"];
    if (currentAttributionStateData == nil) {
        return;
    }
    
    BOOL sendAttribution = [self.attributionTracker sendWhenDelayEnded];
    if (sendAttribution) {
        [self sendAttributionWithSource:@"Delay ended"];
    }
}

- (void)handleAskingAttributionWithString:(nullable NSString *)askingAttribution
                               stopAsking:(BOOL)stopAsking
                                   source:(nonnull NSString *)source {
    if (stopAsking) {
        [self.attributionTracker stopAsking];
        return;
    }
    
    if (askingAttribution == nil) {
        return;
    }
    
    BOOL canSend =
    [self.attributionTracker canSendWhenAskingWithAskingAttribution:askingAttribution];
    
    if (canSend) {
        [self sendAttributionWithSource:source];
    }
}

- (void)handleChangedAttributionStateData:(nullable ADJAttributionStateData *)changedAttributionStateData
                                   source:(nonnull NSString *)source {
    if (changedAttributionStateData == nil) {
        return;
    }
    
    ADJAttributionStateStorage *_Nullable attributionStateStorage =
    self.attributionStateStorageWeak;
    if (attributionStateStorage == nil) {
        [self.logger debugDev:
         @"Cannot change attribution state data without a reference to storage"
                         from:source
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    [attributionStateStorage updateWithNewDataValue:changedAttributionStateData];
}

- (void)handleAttributionStatusEvent:(nullable NSString *)attributionStatusEvent
                              source:(nonnull NSString *)source {
    if (attributionStatusEvent == nil) {
        return;
    }
    
    ADJAttributionStateStorage *_Nullable attributionStateStorage =
    self.attributionStateStorageWeak;
    if (attributionStateStorage == nil) {
        [self.logger debugDev:@"Cannot publish attribution without a reference to storage"
                         from:source
                    issueType:ADJIssueWeakReference];
        return;
    }
    
    ADJAttributionStateData *_Nonnull attributionStateData =
    [attributionStateStorage readOnlyStoredDataValue];
    
    [self.logger debugDev:@"Publishing attribution"
                     from:source
                      key:@"status"
                    value:attributionStatusEvent];
    
    [self.attributionPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJAttributionSubscriber> _Nonnull subscriber)
     {
        [subscriber didAttributionWithData:attributionStateData.attributionData
                         attributionStatus:attributionStatusEvent];
    }];
}

- (void)sendAttributionWithSource:(nonnull NSString *)source {
    ADJAttributionPackageData *_Nullable attributionPackage =
    [self.attributionTracker attributionPackage];
    
    if (attributionPackage == nil) {
        ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
        if (sdkPackageBuilder == nil) {
            [self.logger debugDev:
             @"Cannot send attribution without a reference to package builder"
                        issueType:ADJIssueWeakReference];
            return;
        }
        
        attributionPackage = [sdkPackageBuilder
                              buildAttributionPackageWithInitiatedBy:[self.attributionTracker initiatedBy]];
        
        [self.attributionTracker setAttributionPackageToSendWithData:attributionPackage];
    }
    
    [self.logger debugDev:@"To send sdk package"
                     from:source
                      key:@"package"
                    value:[attributionPackage generateShortDescription].stringValue];
    
    ADJStringMapBuilder *_Nonnull sendingParameters = [self generateSendingParameters];
    
    [self.sender sendSdkPackageWithData:attributionPackage
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)generateSendingParameters {
    ADJStringMapBuilder *_Nonnull sendingParameters =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];
    
    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot inject send at timestamp without a reference to clock"
                    issueType:ADJIssueWeakReference];
    } else {
        [ADJSdkPackageBuilder
         injectSentAtWithParametersBuilder:sendingParameters
         sentAtTimestamp:[clock nonMonotonicNowTimestampMilliWithLogger:self.logger]];
    }
    
    [ADJSdkPackageBuilder
     injectAttemptsWithParametersBuilder:sendingParameters
     attempts:self.attributionTracker.retriesSinceLastSuccessSend.countValue];
    
    return sendingParameters;
}

@end
