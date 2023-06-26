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

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJMainQueueTrackedPackages *trackedPackages;
 */

@interface ADJMainQueueController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStorage *storage;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic)
    ADJMainQueueStateAndTracker *mainQueueStateAndTracker;

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
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"MainQueueController"];
    _storage = mainQueueStorage;
    _clockWeak = clock;

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceLoggerName:self.logger.name];

    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceLoggerName:self.logger.name
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
- (void)
    addAdRevenuePackageToSendWithData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add ad revenue package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:adRevenuePackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)
    addBillingSubscriptionPackageToSendWithData:
        (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add billing subscription package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:billingSubscriptionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addClickPackageToSendWithData:(nonnull ADJClickPackageData *)clickPackageData
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add click package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:clickPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addEventPackageToSendWithData:(nonnull ADJEventPackageData *)eventPackageData
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add event package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:eventPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addInfoPackageToSendWithData:(nonnull ADJInfoPackageData *)infoPackageData
                 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add info package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:infoPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)
    addMeasurementConsentPackageToSendWithData:
        (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add measurement consent package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:measurementConsentPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)addSessionPackageToSendWithData:(nonnull ADJSessionPackageData *)sessionPackageData
                    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add session package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:sessionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)
    addThirdPartySharingPackageToSendWithData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"add third party sharing package"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:thirdPartySharingPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (nonnull NSString *)defaultTargetUrl {
    return [self.sender defaultTargetUrl];
}

#pragma mark - ADJSdkResponseCallbackSubscriber
- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk response"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResponseWithData:sdkResponseData];
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

        [strongSelf handleSdkInit];
    }];
}

#pragma mark - ADJPausingSubscriber
- (void)didResumeSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"resume sending"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleResumeSending];
    }];
}

- (void)didPauseSendingWithSource:(nonnull NSString *)source {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"pause sending"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.mainQueueStateAndTracker pauseSending];
    }];
}

#pragma mark - ADJOfflineSubscriber
- (void)didSdkBecomeOnline {
    // do nothing, wait for pausing subscription
}

- (void)didSdkBecomeOffline {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                              from:@"sdk become offline"
                                             block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf.mainQueueStateAndTracker pauseSending];
    }];
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
        NSString *_Nonnull from = [NSString stringWithFormat:@"%@ added",
                                     [sdkPackageDataToAdd generateShortDescription]];

        [self sendPackageWithData:packageAtFront
                           from:from];
    }
}

- (void)handleSdkInit {
    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenSdkInitWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           from:@"sdk init"];
    }
}

- (void)handleResumeSending {
    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenResumeSendingWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           from:@"resume sending"];
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
                           from:@"handle response"];
    }
}

- (void)removePackageAtFrontWithSourceResponsePackage:
    (nonnull id<ADJSdkPackageData>)sourceResponsePackage
{
    ADJNonNegativeInt *_Nullable positionAtFront =
        [self positionOfPackageWithWithSourceResponsePackage:sourceResponsePackage];

    if (positionAtFront == nil) {
        [self.logger debugDev:@"Could not obtain position at front to remove package at front"
                    issueType:ADJIssueStorageIo];
        return;
    }

    ADJSQLiteStorageActionBase *_Nullable updateMetadataSqliteStorageAction =
        [self.trackedPackages decrementTrackedCountWithPackageToRemove:sourceResponsePackage];

    id<ADJSdkPackageData> _Nullable removedSdkPackage =
        [self.storage removeElementByPosition:positionAtFront
                          sqliteStorageAction:updateMetadataSqliteStorageAction];

    if (! [sourceResponsePackage isEqual:removedSdkPackage]) {
        [self.logger debugWithMessage:
         @"Unexpected difference between package from response and removed at position in front"
                         builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
            [logBuilder withKey:@"package from response"
                    stringValue:sourceResponsePackage.description];
            [logBuilder withKey:@"position at front"
                    stringValue:positionAtFront.description];
            [logBuilder withKey:@"element at position at front"
                    stringValue:removedSdkPackage != nil ? [removedSdkPackage description] : nil];
            [logBuilder issue:ADJIssueStorageIo];
        }];
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
                 stringValue1:sourceResponsePackage.description
                         key2:@"package at front"
                 stringValue2:[self.storage elementAtFront].description
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJNonNegativeInt *_Nullable positionAtFront = [self.storage positionAtFront];
    id _Nullable elementAtFrontPosition = [self.storage elementByPosition:positionAtFront];
    if (! [sourceResponsePackage isEqual:elementAtFrontPosition]) {
        [self.logger debugWithMessage:
         @"Unexpected difference between package from response and at position in front"
                         builderBlock:^(ADJLogBuilder *_Nonnull logBuilder) {
            [logBuilder withKey:@"package from response"
                    stringValue:sourceResponsePackage.description];
            [logBuilder withKey:@"position at front"
                    stringValue:positionAtFront != nil ? positionAtFront.description : nil];
            [logBuilder withKey:@"element at position at front"
                    stringValue:
             elementAtFrontPosition != nil ? [elementAtFrontPosition description] : nil];
            [logBuilder issue:ADJIssueStorageIo];
        }];
        return nil;
    }

    return positionAtFront;
}

- (void)delaySendWithData:(nonnull ADJDelayData *)delayData {
    __typeof(self) __weak weakSelf = self;
    [self.executor scheduleInSequenceWithLogger:self.logger
                                           from:@"delay end"
                           delayTimeMilli:delayData.delay
                                    block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleDelayEndWithSource:delayData.from];
    }];
}

- (void)handleDelayEndWithSource:(nonnull NSString *)from {
    [self.logger debugDev:@"Delay ended"
                     from:from];

    id<ADJSdkPackageData> _Nullable packageAtFront = [self.storage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
         sendWhenDelayEndedWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                           from:@"handle delay end"];
    }
}

- (void)sendPackageWithData:(nullable id<ADJSdkPackageData>)packageToSend
                       from:(nonnull NSString *)from
{
    if (packageToSend == nil) {
        [self.logger debugDev:@"Cannot send package it is nil"
                         from:from];
        return;
    }

    [self.logger debugDev:@"To send sdk package"
                     from:from
                      key:@"package"
              stringValue:[packageToSend generateShortDescription].stringValue];

    ADJStringMapBuilder *_Nonnull sendingParameters =
        [self generateSendingParametersWithStorage:self.storage];

    [self.sender sendSdkPackageWithData:packageToSend
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)
    generateSendingParametersWithStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage
{
    ADJStringMapBuilder *_Nonnull sendingParameters =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

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

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot inject sent at without a reference to clock"
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
