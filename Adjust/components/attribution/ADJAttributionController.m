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
@interface ADJAttributionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionStateStorage *storage;
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJAttributionPublisher *attributionPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionTracker *attributionTracker;
@property (nonnull, readonly, strong, nonatomic) ADJAttributionState *attributionState;
@property (nullable, readwrite, strong, nonatomic)
    ADJAttributionPackageData *attributionPackageToSend;
@property (readwrite, assign, nonatomic) BOOL canPublish;

@end

@implementation ADJAttributionController
#pragma mark Instantiation
+ (nonnull ADJAttributionController *)
    instanceWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clock:(nonnull ADJClock *)clock
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    threadController:(nonnull ADJThreadController *)threadController
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
    mainQueueTrackedPackages:
        (nonnull ADJMainQueueTrackedPackages *)mainQueueTrackedPackages
    doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    ADJAttributionController *_Nonnull attributionController =
        [[ADJAttributionController alloc] initWithLoggerFactory:loggerFactory
                                        attributionStateStorage:attributionStateStorage
                                                          clock:clock
                                              sdkPackageBuilder:sdkPackageBuilder
                                               threadController:threadController
                                     attributionBackoffStrategy:attributionBackoffStrategy
                                        sdkPackageSenderFactory:sdkPackageSenderFactory
                                doNotInitiateAttributionFromSdk:doNotInitiateAttributionFromSdk
                                            publisherController:publisherController];

    ADJNonNegativeInt *_Nullable firstSessionCount =
        [mainQueueTrackedPackages firstSessionCount];
    BOOL hasTrackedInstallSession = firstSessionCount != nil
        && firstSessionCount.uIntegerValue == 0;

    if (hasTrackedInstallSession) {
        [attributionController installSessionTrackedAtLoad];
    }

    return attributionController;
}
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    attributionStateStorage:(nonnull ADJAttributionStateStorage *)attributionStateStorage
    clock:(nonnull ADJClock *)clock
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    threadController:(nonnull ADJThreadController *)threadController
    attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
    doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"AttributionController"];
    _storage = attributionStateStorage;
    _clock = clock;
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    
    _attributionPublisher = [[ADJAttributionPublisher alloc]
                             initWithSubscriberProtocol:@protocol(ADJAttributionSubscriber)
                             controller:publisherController];
    
    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];
    
    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceDescription:self.source
                                                         threadExecutorFactory:threadController];

    ADJAttributionStateData *_Nonnull initialStateData =
        [attributionStateStorage readOnlyStoredDataValue];

    _attributionTracker = [[ADJAttributionTracker alloc]
                           initWithLoggerFactory:loggerFactory
                           attributionBackoffStrategy:attributionBackoffStrategy
                           startsAsking:[initialStateData isAskingStatus]];

    _attributionState = [[ADJAttributionState alloc]
                         initWithLoggerFactory:loggerFactory
                         initialStateData:initialStateData
                         doNotInitiateAttributionFromSdk:doNotInitiateAttributionFromSdk];

    _attributionPackageToSend = nil;

    _canPublish = NO;

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
        
        [strongSelf attributionResponseWithData:attributionResponseData];
    } source:@"received attribution response"];
}
- (void)attributionResponseWithData:(nonnull ADJAttributionResponseData *)attributionResponse {
    ADJDelayData *_Nullable delay =
        [self.attributionTracker
         delaySendingWhenReceivedAttributionResponseWithData:attributionResponse];

    if (delay != nil) {
        [self handleDelay:delay
                   source:@"attributionResponse from tracker"];
        return;
    }

    // nil delay implies accepted package

    // -> should not usee the same package again
    self.attributionPackageToSend = nil;

    ADJAttributionStateOutputData *_Nullable output =
        [self.attributionState receivedAcceptedAttributionResponse:attributionResponse];

    [self handleSideEffectsWithOutputData:output source:@"attributionResponse from state"];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.canPublish = YES;

        ADJAttributionStateData *_Nonnull stateData = [strongSelf.storage readOnlyStoredDataValue];

        [strongSelf handlePublishWithStateData:stateData
                           previousAttribution:stateData.attributionData
                                        source:@"allowed to publish"];
    } source:@"allowed to publish"];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (sdkResponseData.shouldRetry) {
        return;
    }

    // ignore attribution in the response subscription, since they have already been handled
    //  in the direct response callback
    if ([sdkResponseData isKindOfClass:[ADJAttributionResponseData class]]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAcceptedNonAttributionResponse:sdkResponseData];
    } source:@"received sdk response"];
}
/**
 The order checked here is important.
 1. First looking for AskIn, a delay command from the backend
 2. Only then if it's also a first install tracked, which might make it possible to track attribution

 If reversed,  the first install tracked would start requesting attribution without considering the askIn delay from the backend
 */
- (void)handleAcceptedNonAttributionResponse:
    (nonnull id<ADJSdkResponseData>)nonAttributionResponse
{
    // Loking for askIn to delay attribution request
    ADJAttributionStateOutputData *_Nullable outputData =
        [self.attributionState receivedAcceptedNonAttributionResponse:nonAttributionResponse];

    [self handleSideEffectsWithOutputData:outputData source:@"accepted non attribution response"];

    if ([ADJMainQueueTrackedPackages
         isFirstSessionPackageWithData:nonAttributionResponse.sourcePackage])
    {
        // Figuring out if it can request attribution without an askIn
        ADJAttributionStateOutputData *_Nullable outputData =
            [self.attributionState installSessionTracked];

        [self handleSideEffectsWithOutputData:outputData source:@"accepted install session response"];
    }
}

#pragma mark - ADJSdkStartSubscriber
- (void)ccSdkStart {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJAttributionStateOutputData *_Nullable outputData =
            [strongSelf.attributionState sdkStart];

        [strongSelf handleSideEffectsWithOutputData:outputData source:@"sdk start"];
    } source:@"sdk start"];
}

#pragma mark - ADJPausingSubscriber
- (void)didResumeSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if ([strongSelf.attributionTracker sendWhenSdkResumingSending]) {
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
- (void)installSessionTrackedAtLoad {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJAttributionStateOutputData *_Nullable outputData =
            [strongSelf.attributionState installSessionTracked];

        [strongSelf handleSideEffectsWithOutputData:outputData
                                             source:@"install session tracked at load"];
    } source:@"install session tracked at load"];
}

- (void)handleSideEffectsWithOutputData:(nullable ADJAttributionStateOutputData *)outputData
                                 source:(nonnull NSString *)source
{
    if (outputData == nil) {
        return;
    }

    ADJAttributionData *_Nullable previousAttribution =
        [self handleChangedStateData:outputData.changedStateData];

    [self handlePublishWithStateData:outputData.changedStateData
                 previousAttribution:previousAttribution
                              source:source];

    [self handleDelay:outputData.delayData
               source:source];

    [self handleAskingCommand:outputData.startAsking source:source];
}

- (nullable ADJAttributionData *)handleChangedStateData:
    (nullable ADJAttributionStateData *)changedStateData
{
    if (changedStateData == nil) { return nil; }

    ADJAttributionStateData *_Nonnull stateDataBeforeUpdate =
        [self.storage readOnlyStoredDataValue];

    [self.storage updateWithNewDataValue:changedStateData];

    return stateDataBeforeUpdate.attributionData;
}

- (void)handlePublishWithStateData:(nullable ADJAttributionStateData *)stateData
               previousAttribution:(nullable ADJAttributionData *)previousAttribution
                            source:(nonnull NSString *)source
{
    if (stateData == nil) { return; }
    if (! self.canPublish) { return; }

    [self.logger debugDev:@"Publishing attribution state"
                     from:source];

    [self.attributionPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJAttributionSubscriber> _Nonnull subscriber)
     {
        [subscriber attributionWithStateData:stateData
                         previousAttribution:previousAttribution];
    }];
}

- (void)handleDelay:(nullable ADJDelayData *)delayData
             source:(nonnull NSString *)source
{
    if (delayData == nil) {
        return;
    }

    if (! [self.attributionTracker tryToDelay]) {
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
                        source:(nonnull NSString *)source
{
    [self.logger debugDev:@"Delay ended"
                     from:source
                      key:@"delayReason"
                    value:delayData.source];

    if ([self.attributionTracker sendWhenDelayEnded]) {
        [self sendAttributionWithSource:@"Delay ended"];
    }
}

- (void)handleAskingCommand:(BOOL)startAsking
                     source:(nonnull NSString *)source
{
    if (! startAsking) { return; }

    if ([self.attributionTracker sendWhenStartAsking]) {
        [self sendAttributionWithSource:source];
    }
}

- (void)sendAttributionWithSource:(nonnull NSString *)source {
    ADJAttributionPackageData *_Nullable attributionPackage = [self getOrCreateAttributionPackage];
    if (attributionPackage == nil) {
        return;
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
    
    [ADJSdkPackageBuilder
     injectSentAtWithParametersBuilder:sendingParameters
     sentAtTimestamp:[self.clock nonMonotonicNowTimestampMilliWithLogger:self.logger]];
    
    [ADJSdkPackageBuilder
     injectAttemptsWithParametersBuilder:sendingParameters
     attempts:self.attributionTracker.retriesSinceLastSuccessSend.countValue];
    
    return sendingParameters;
}

- (nullable ADJAttributionPackageData *)getOrCreateAttributionPackage {
    if (self.attributionPackageToSend == nil) {
        ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
        if (sdkPackageBuilder == nil) {
            [self.logger debugDev:
                @"Cannot send attribution without a reference to package builder"
                        issueType:ADJIssueWeakReference];
            return nil;
        }

        self.attributionPackageToSend = [sdkPackageBuilder buildAttributionPackage];
    }

    return self.attributionPackageToSend;
}

@end
