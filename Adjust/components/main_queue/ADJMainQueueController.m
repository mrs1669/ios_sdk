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
#import "ADJConstantsParam.h"

#pragma mark Fields
@interface ADJMainQueueController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJMainQueueStorage *mainQueueStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSender *sender;
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStateAndTracker *mainQueueStateAndTracker;

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
    _mainQueueStorageWeak = mainQueueStorage;
    _clockWeak = clock;

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                            sourceDescription:self.source];

    _sender = [sdkPackageSenderFactory createSdkPackageSenderWithLoggerFactory:loggerFactory
                                                             sourceDescription:self.source
                                                                    threadpool:threadController];

    _mainQueueStateAndTracker =
        [[ADJMainQueueStateAndTracker alloc] initWithLoggerFactory:loggerFactory
                                                    backoffStrategy:backoffStrategy];

    return self;
}

#pragma mark Public API
// TODO possibly move containsXpackage responsability to their callers
- (BOOL)containsFirstSessionPackage {
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot determine if it contains first session package"
            " without a reference to storage"];
        return NO;
    }

    NSArray<id<ADJSdkPackageData>> *_Nonnull sdkPackageDataListCopy =
        [mainQueueStorage copyElementList];

    for (id<ADJSdkPackageData> _Nonnull sdkPackageData in sdkPackageDataListCopy) {
        if ([self isFirstSessionPackageWithSdkPackage:sdkPackageData]) {
            return YES;
        }
    }

    return NO;
}

/*
- (BOOL)containsAsaClickPackage {
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot determine if it contains first session package"
            " without a reference to storage"];
        return NO;
    }

    NSArray<id<ADJSdkPackageData>> *_Nonnull sdkPackageDataListCopy = [mainQueueStorage copyElementList];

    for (id<ADJSdkPackageData> _Nonnull sdkPackageData in sdkPackageDataListCopy) {
        if ([self isAsaClickPackageWithData:sdkPackageData]) {
            return YES;
        }
    }

    return NO;
}

 - (void)
    addAdRevenuePackageToSendWithData:
        (nonnull ADJAdRevenuePackageData *)adRevenuePackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
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
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:billingSubscriptionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

- (void)
    addClickPackageToSendWithData:(nonnull ADJClickPackageData *)clickPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:clickPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}
*/

- (void) addEventPackageToSendWithData:(nonnull ADJEventPackageData *)eventPackageData
                   sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction {
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:eventPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}

/*
- (void)
    addInfoPackageToSendWithData:(nonnull ADJInfoPackageData *)infoPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:infoPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}
*/
- (void)
    addSessionPackageToSendWithData:(nonnull ADJSessionPackageData *)sessionPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:sessionPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}
/*
- (void)
    addThirdPartySharingPackageToSendWithData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf addSdkPackageToSendWithData:thirdPartySharingPackageData
                            sqliteStorageAction:sqliteStorageAction];
    }];
}
*/
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
    }];
}

#pragma mark - ADJSdkInitSubscriber
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

        [strongSelf.mainQueueStateAndTracker pauseSending];
    }];
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
    }];
}

#pragma mark - Subscriptions
- (void)
    ccSubscribeToPublishersWithSdkInitPublisher:
        (nonnull ADJSdkInitPublisher *)sdkInitPublisher
    pausingPublisher:(nonnull ADJPausingPublisher *)pausingPublisher
    offlinePublisher:(nonnull ADJOfflinePublisher *)offlinePublisher
{
    [sdkInitPublisher addSubscriber:self];
    [pausingPublisher addSubscriber:self];
    [offlinePublisher addSubscriber:self];
}

#pragma mark Internal Methods
- (void)
    addSdkPackageToSendWithData:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot add sdk package to send"
            " without a reference to the storage"];
        [ADJUtilSys finalizeAtRuntime:sqliteStorageAction];
        return;
    }

    [mainQueueStorage enqueueElementToLast:sdkPackageDataToAdd
                       sqliteStorageAction:sqliteStorageAction];

    id<ADJSdkPackageData> _Nullable packageAtFront = [mainQueueStorage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker sendWhenPackageAddedWithPackage:sdkPackageDataToAdd
                                              mainQueueSdkPackageCount:[mainQueueStorage count]
                                                     hasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        NSString *_Nonnull source = [NSString stringWithFormat:@"%@ added",
                                     [sdkPackageDataToAdd generateShortDescription]];

        [self sendPackageWithData:packageAtFront
                 mainQueueStorage:mainQueueStorage
                           source:source];
    }
}

- (BOOL)isFirstSessionPackageWithSdkPackage:(nullable id<ADJSdkPackageData>)sdkPackageData {
    if (sdkPackageData == nil
        || ! [sdkPackageData isKindOfClass:[ADJSessionPackageData class]])
    {
        return NO;
    }

    ADJSessionPackageData *_Nonnull sessionPackageData = (ADJSessionPackageData *)sdkPackageData;

    return [sessionPackageData isFirstSession];
}

/*
- (BOOL)isAsaClickPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData {
    if (! [sdkPackageData.path isEqualToString:ADJClickPackageDataPath]) {
        return NO;
    }

    ADJNonEmptyString *_Nullable clickSourceValue =
        [sdkPackageData.parameters pairValueWithKey:ADJParamClickSourceKey];
    if (clickSourceValue == nil) {
        return NO;
    }

    return [clickSourceValue.stringValue isEqualToString:ADJParamAsaAttributionClickSourceValue];
}
 
*/

- (void)handleSdkInit {
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot handle sdk init"
            " without a reference to the storage"];
        return;
    }

    id<ADJSdkPackageData> _Nullable packageAtFront = [mainQueueStorage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
            sendWhenSdkInitWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                 mainQueueStorage:mainQueueStorage
                           source:@"sdk init"];
    }
}

- (void)handleResumeSending {
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot handle resuming sending without a reference to the storage"];
        return;
    }

    id<ADJSdkPackageData> _Nullable packageAtFront = [mainQueueStorage elementAtFront];

    BOOL sendPackageAtFront = [self.mainQueueStateAndTracker sendWhenResumeSendingWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                 mainQueueStorage:mainQueueStorage
                           source:@"resume sending"];
    }
}

- (void)handleResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot handle response without a reference to the storage"];
        return;
    }

    ADJMainQueueResponseProcessingData *_Nonnull mainQueueResponseProcessingData =
        [self.mainQueueStateAndTracker processReceivedSdkResponseWithData:sdkResponseData];

    if (mainQueueResponseProcessingData.removePackageAtFront) {
        [self removePackageAtFrontWithStorage:mainQueueStorage];
    }

    if (mainQueueResponseProcessingData.delayData != nil) {
        [self delaySendWithData:mainQueueResponseProcessingData.delayData];
        return;
    }

    id<ADJSdkPackageData> _Nullable packageAtFront = [mainQueueStorage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
            sendAfterProcessingSdkResponseWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                 mainQueueStorage:mainQueueStorage
                           source:@"handle response"];
    }
}

- (void)removePackageAtFrontWithStorage:(nonnull ADJMainQueueStorage *)storage {
    id<ADJSdkPackageData> _Nullable removedSdkPackage = [storage removeElementAtFront];

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

    ADJMainQueueStorage *_Nullable mainQueueStorage = self.mainQueueStorageWeak;
    if (mainQueueStorage == nil) {
        [self.logger error:@"Cannot handle delay end"
            " without a reference to the storage"];
        return;
    }

    id<ADJSdkPackageData> _Nullable packageAtFront = [mainQueueStorage elementAtFront];

    BOOL sendPackageAtFront =
        [self.mainQueueStateAndTracker
            sendWhenDelayEndedWithHasPackageAtFront:packageAtFront != nil];

    if (sendPackageAtFront) {
        [self sendPackageWithData:packageAtFront
                 mainQueueStorage:mainQueueStorage
                           source:@"handle delay end"];
    }
}

- (void)sendPackageWithData:(nullable id<ADJSdkPackageData>)packageToSend
           mainQueueStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage
                     source:(nonnull NSString *)source
{
    if (packageToSend == nil) {
        [self.logger error:@"Cannot send package from %@ when it is nil", source];
        return;
    }

    [self.logger debug:@"To send sdk package %@ from %@",
        [packageToSend generateShortDescription],
        source];

    ADJStringMapBuilder *_Nonnull sendingParameters =
        [self generateSendingParametersWithStorage:mainQueueStorage];

    [self.sender sendSdkPackageWithData:packageToSend
                      sendingParameters:sendingParameters
                       responseCallback:self];
}

- (nonnull ADJStringMapBuilder *)generateSendingParametersWithStorage:
    (nonnull ADJMainQueueStorage *)mainQueueStorage
{
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
        [self.logger error:@"Cannot inject remaining queue sizy"
            " when its empty"];
    }

    return sendingParameters;
}

@end
