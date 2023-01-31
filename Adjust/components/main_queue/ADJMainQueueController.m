//
//  ADJMainQueueController.m
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMainQueueController.h"

#import "ADJSingleThreadExecutor.h"
#import "ADJMainQueueStateAndTracker.h"
#import "ADJNonNegativeInt.h"
#import "ADJSdkPackageData.h"
#import "ADJSdkPackageBuilder.h"
#import "ADJUtilSys.h"
#import "ADJUtilF.h"
#import "ADJConstantsParam.h"
#import "ADJSQLiteStorageQueueMetadataAction.h"
#import "ADJMainQueueTrackedPackages.h"

#pragma mark Fields
@interface ADJMainQueueController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStorage *storage;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStateAndTracker *mainQueueStateAndTracker;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueTrackedPackages *trackedPackages;

@end

@implementation ADJMainQueueController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    mainQueueStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage
    threadController:(nonnull ADJThreadController *)threadController
    clock:(nonnull ADJClock *)clock
    backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
{
    self = [super initWithLoggerFactory:loggerFactory source:@"MainQueueController"];
    _storage = mainQueueStorage;
    _clockWeak = clock;

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];

    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceDescription:self.source
                                                         threadExecutorFactory:threadController];

    _mainQueueStateAndTracker =
        [[ADJMainQueueStateAndTracker alloc] initWithLoggerFactory:loggerFactory
                                                   backoffStrategy:backoffStrategy];

    _trackedPackages = [[ADJMainQueueTrackedPackages alloc]
                        initWithLoggerFactory:loggerFactory
                        mainQueueStorage:mainQueueStorage];

    return self;
}

#pragma mark Public API
- (nullable ADJNonNegativeInt *)firstSessionCount {
    return [self.trackedPackages firstSessionCount];
}
- (nullable ADJNonNegativeInt *)asaClickCount {
    return [self.trackedPackages asaClickCount];
}
- (nonnull ADJInstallSessionTrackedPublisher *)installSessionTrackedPublisher {
    return [self.trackedPackages installSessionTrackedPublisher];
}
- (nonnull ADJAsaClickTrackedPublisher *)asaClickTrackedPublisher {
    return [self.trackedPackages asaClickTrackedPublisher];
}

- (void)addAdRevenuePackageToSendWithData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
                      sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:adRevenuePackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add ad revenue package"];
}

- (void)addBillingSubscriptionPackageToSendWithData:
(nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
                                sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:billingSubscriptionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add billing subscription package"];
}

- (void)addClickPackageToSendWithData:(nonnull ADJClickPackageData *)clickPackageData
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:clickPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add click package"];
}

- (void)addEventPackageToSendWithData:(nonnull ADJEventPackageData *)eventPackageData
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:eventPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add event package"];
}

- (void)addInfoPackageToSendWithData:(nonnull ADJInfoPackageData *)infoPackageData
                 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:infoPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add info package"];
}

- (void)addSessionPackageToSendWithData:(nonnull ADJSessionPackageData *)sessionPackageData
                    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:sessionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add session package"];
}

- (void)addThirdPartySharingPackageToSendWithData:
(nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
                              sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:thirdPartySharingPackageData
                            sqliteStorageAction:sqliteStorageAction];
    } source:@"add third party sharing package"];
}

- (nonnull NSString *)defaultTargetUrl {
    return [self.sender defaultTargetUrl];
}

#pragma mark - ADJSdkResponseCallbackSubscriber
- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResponseWithData:sdkResponseData];
    } source:@"sdk response"];
}

#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleSdkInit];
    } source:@"sdk init"];
}

#pragma mark - ADJPausingSubscriber
- (void)didResumeSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResumeSending];
    } source:@"resume sending"];
}

- (void)didPauseSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.mainQueueStateAndTracker pauseSending];
    } source:@"pause sending"];
}

#pragma mark - ADJOfflineSubscriber
- (void)didSdkBecomeOnline {
    // do nothing, wait for pausing subscription
}

- (void)didSdkBecomeOffline {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.mainQueueStateAndTracker pauseSending];
    } source:@"sdk become offline"];
}

#pragma mark Internal Methods
- (void)addSdkPackageToSendWithData:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
                sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    ADJSQLiteStorageActionBase *_Nullable decoratedSqliteStorageAction =
        [self.trackedPackages incrementTrackedCountWithPackageToAdd:sdkPackageDataToAdd
                                          sqliteStorageActionForAdd:sqliteStorageAction];

    [self.storage enqueueElementToLast:sdkPackageDataToAdd
                   sqliteStorageAction:decoratedSqliteStorageAction];

    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];
    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker sendWhenPackageAddedWithPackage:sdkPackageDataToAdd
                                              mainQueueSdkPackageCount:[self.storage count]
                                                     hasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        NSString *_Nonnull source = [NSString stringWithFormat:@"%@ added",
                                     [sdkPackageDataToAdd generateShortDescription]];

        [self sendPackageWithData:packageAtFront
                           source:source];
    }
}

- (void)handleSdkInit {
    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenSdkInitWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           source:@"sdk init"];
    }
}

- (void)handleResumeSending {
    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenResumeSendingWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           source:@"resume sending"];
    }
}

- (void)handleResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    ADJMainQueueResponseProcessingData *_Nonnull mainQueueResponseProcessingData =
        [self.mainQueueStateAndTracker processReceivedSdkResponseWithData:sdkResponseData];

    if (mainQueueResponseProcessingData.removePackageAtFront) {
        [self removePackageAtFrontWithSourceResponsePackage:sdkResponseData.sourcePackage];
    }

    if (mainQueueResponseProcessingData.delayData != nil) {
        [self delaySendWithData:mainQueueResponseProcessingData.delayData];
        return;
    }

    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
    [self.mainQueueStateAndTracker
     sendAfterProcessingSdkResponseWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           source:@"handle response"];
    }
}

- (void)removePackageAtFrontWithSourceResponsePackage:
    (nonnull id<ADJSdkPackageData>)sourceResponsePackage
{
    ADJNonNegativeInt *_Nullable positionAtFront =
        [self positionOfPackageWithWithSourceResponsePackage:sourceResponsePackage];

    ADJSQLiteStorageActionBase *_Nullable updateMetadataSqliteStorageAction =
        [self.trackedPackages decrementTrackedCountWithPackageToRemove:sourceResponsePackage];

    id<ADJSdkPackageData> _Nullable removedSdkPackage =
        [self.storage removeElementByPosition:positionAtFront
                          sqliteStorageAction:updateMetadataSqliteStorageAction];

    if (! [sourceResponsePackage isEqual:removedSdkPackage]) {
        [self.logger debugDev:
         @"Unexpected difference between packages from response and removed at position in front"
                messageParams:
         [[NSDictionary alloc] initWithObjectsAndKeys:
          [ADJUtilF stringOrNsNull:sourceResponsePackage.description],
            @"package from response",
          [ADJUtilF stringOrNsNull:positionAtFront.description],
            @"position at front",
          [ADJUtilF stringOrNsNull:removedSdkPackage.description],
            @"package removed at position at front",
          nil]
                    issueType:ADJIssueStorageIo];
        return;
    }

    [self.logger debugDev:@"Package at front removed"];
}

- (nullable ADJNonNegativeInt *)positionOfPackageWithWithSourceResponsePackage:
    (nonnull id<ADJSdkPackageData>)sourceResponsePackage
{
    if (! [sourceResponsePackage isEqual:[self.storage elementAtFront]]) {
        [self.logger debugDev:@"Unexpected difference between packages from response and at front"
                         key1:@"package from response"
                       value1:sourceResponsePackage.description
                         key2:@"package at front"
                       value2:[self.storage elementAtFront].description
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJNonNegativeInt *_Nullable positionAtFront = [self.storage positionAtFront];
    if (! [sourceResponsePackage isEqual:[self.storage elementByPosition:positionAtFront]]) {
        [self.logger debugDev:
         @"Unexpected difference between packages from response and at position in front"
                messageParams:
         [[NSDictionary alloc] initWithObjectsAndKeys:
          [ADJUtilF stringOrNsNull:sourceResponsePackage.description],
            @"package from response",
          [ADJUtilF stringOrNsNull:positionAtFront.description],
            @"position at front",
          [ADJUtilF stringOrNsNull:[self.storage elementByPosition:positionAtFront].description],
            @"package at position at front",
          nil]
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    return positionAtFront;
}

- (void)delaySendWithData:(nonnull ADJDelayData *)delayData {
    __typeof(self) __weak weakSelf = self;
    [self.executor
     scheduleInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleDelayEndWithSource:delayData.source];
    }
     delayTimeMilli:delayData.delay
     source:@"delay end"];
}

- (void)handleDelayEndWithSource:(nonnull NSString *)source {
    [self.logger debugDev:@"Delay ended"
                     from:source];

    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenDelayEndedWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           source:@"handle delay end"];
    }
}

- (void)sendPackageWithData:(nullable id<ADJSdkPackageData>)packageToSend
                     source:(nonnull NSString *)source
{
    if (packageToSend == nil) {
        [self.logger debugDev:@"Cannot send package it is nil"
                         from:source];
        return;
    }

    [self.logger debugDev:@"To send sdk package"
                     from:source
                      key:@"package"
                    value:[packageToSend generateShortDescription].stringValue];

    ADJStringMapBuilder *_Nonnull sendingParameters =
        [self generateSendingParametersWithStorage:self.storage];

    [self.sender sendSdkPackageWithData:packageToSend
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)generateSendingParametersWithStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage {
    ADJStringMapBuilder *_Nonnull sendingParameters = [[ADJStringMapBuilder alloc] initWithEmptyMap];

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock != nil) {
        [ADJSdkPackageBuilder
         injectSentAtWithParametersBuilder:sendingParameters
         sentAtTimestamp:[clock nonMonotonicNowTimestampMilliWithLogger:self.logger]];
    } else {
        [self.logger debugDev:@"Cannot inject sent at without a reference to clock"
                    issueType:ADJIssueWeakReference];
    }

    [ADJSdkPackageBuilder
     injectAttemptsWithParametersBuilder:sendingParameters
     attempts:[self.mainQueueStateAndTracker retriesSinceLastSuccessSend]];

    ADJNonNegativeInt *_Nonnull currentQueueSize = [mainQueueStorage count];

    if (currentQueueSize.uIntegerValue > 0) {
        ADJNonNegativeInt *_Nonnull remaingQueueSize =
        [[ADJNonNegativeInt alloc] initWithUIntegerValue:
         currentQueueSize.uIntegerValue - 1];

        [ADJSdkPackageBuilder
         injectRemainingQueuSizeWithParametersBuilder:sendingParameters
         remainingQueueSize:remaingQueueSize];
    } else {
        [self.logger debugDev:@"Cannot inject remaining queue size when its empty"
                    issueType:ADJIssueLogicError];
    }

    return sendingParameters;
}

@end
