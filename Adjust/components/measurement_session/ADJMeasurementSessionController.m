//
//  ADJMeasurementSessionController.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementSessionController.h"

#import "ADJMeasurementSessionState.h"
#import "ADJMeasurementSessionStateStorageAction.h"
#import "ADJUtilSys.h"

#pragma mark Private class
@implementation ADJMeasurementSessionStartPublisher @end
@implementation ADJPreFirstMeasurementSessionStartPublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic)
  ADJMeasurementSessionStartPublisher *measurementSessionStartPublisher;
 @property (nonnull, readonly, strong, nonatomic)
  ADJPreFirstMeasurementSessionStartPublisher *preFirstMeasurementSessionStartPublisher;
 */

@interface ADJMeasurementSessionController ()
#pragma mark - Injected dependencies
@property (nullable, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
@property (nullable, readonly, weak, nonatomic) ADJSingleThreadExecutor *clientExecutorWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic)
    ADJMeasurementSessionStateStorage *measurementSessionStateStorageWeak;
@property (nullable, readonly, weak, nonatomic)
    ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionState *measurementSessionState;

@end

@implementation ADJMeasurementSessionController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    minMeasurementSessionIntervalMilli:(nonnull ADJTimeLengthMilli *)minMeasurementSessionIntervalMilli
    overwriteFirstMeasurementSessionIntervalMilli:
        (nullable ADJTimeLengthMilli *)overwriteFirstMeasurementSessionIntervalMilli
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    clock:(nonnull ADJClock *)clock
{
    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementSessionController"];
    _overwriteFirstMeasurementSessionIntervalMilli = overwriteFirstMeasurementSessionIntervalMilli;
    _clientExecutorWeak = clientExecutor;
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _measurementSessionStateStorageWeak = measurementSessionStateStorage;
    _mainQueueControllerWeak = mainQueueController;
    _clockWeak = clock;

    _preFirstMeasurementSessionStartPublisher = [[ADJPreFirstMeasurementSessionStartPublisher alloc] init];

    _measurementSessionStartPublisher = [[ADJMeasurementSessionStartPublisher alloc] init];

    _measurementSessionState = [[ADJMeasurementSessionState alloc]
                            initWithLoggerFactory:loggerFactory
                            minMeasurementSessionIntervalMilli:minMeasurementSessionIntervalMilli];

    return self;
}

#pragma mark Public API
- (void)ccForeground {
    [self processForegroundWithSource:@"ccForeground"];
}

- (void)ccBackground {
    [self processBackground];
}

- (nullable ADJMeasurementSessionStateData *)currentMeasurementSessionStateDataWithLogger:
    (nonnull ADJLogger *)logger
{
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;

    if (measurementSessionStateStorage == nil) {
        [self.logger error:@"Cannot get current sdk session state data"
            " without a reference to storage"];
        return nil;
    }

    return [measurementSessionStateStorage readOnlyStoredDataValue];
}

#pragma mark - Subscriptions
- (void)
    ccSubscribeToPublishersWithSdkActivePublisher:
        (nonnull ADJSdkActivePublisher *)sdkActivePublisher
    sdkInitPublisher:(nonnull ADJSdkInitPublisher *)sdkInitPublisher
    keepAlivePublisher:(nonnull ADJKeepAlivePublisher *)keepAlivePublisher
    lifecyclePublisher:(nonnull ADJLifecyclePublisher *)lifecyclePublisher
{
    [sdkActivePublisher addSubscriber:self];
    [sdkInitPublisher addSubscriber:self];
    [keepAlivePublisher addSubscriber:self];
    [lifecyclePublisher addSubscriber:self];
}

#pragma mark - ADJSdkActiveSubscriber
- (void)ccSdkActiveWithStatus:(nonnull NSString *)status {
    [self.logger debug:@"Handling ccSdkActiveState with status: %@", status];

    if ([ADJSdkActiveStatusActive isEqual:status]) {
        [self sdkBecameActive];
    } else {
        [self sdkBecameNotActive];
    }
}

#pragma mark - ADJSdkInitSubscriber
- (void)ccOnSdkInitWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData {
    BOOL canMeasurementSessionBecomeActive = [self.measurementSessionState canMeasurementSessionBecomeActiveWhenSdkInit];

    if (canMeasurementSessionBecomeActive) {
        [self changeToActiveSessionWithSource:@"SdkInit"];
    }
}

#pragma mark - ADJKeepAliveSubscriber
- (void)didKeepAlivePing {
    ADJSingleThreadExecutor *_Nullable clientExecutor = self.clientExecutorWeak;
    if (clientExecutor == nil) {
        [self.logger error:@"Cannot process Keep Alive Ping without a reference to"
            " client executor"];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processKeepAlivePing];
    }];
}

#pragma mark - ADJLifecycleSubscriber
- (void)onForegroundWithIsFromClientContext:(BOOL)isFromClientContext {
    // no need to process foreground from client,
    //  since it's already processed by 'ccForeground'
    if (isFromClientContext) {
        return;
    }

    ADJSingleThreadExecutor *_Nullable clientExecutor = self.clientExecutorWeak;
    if (clientExecutor == nil) {
        [self.logger error:@"Cannot process Foreground without a reference to"
            " client executor"];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processForegroundWithSource:@"onForeground"];
    }];
}

- (void)onBackgroundWithIsFromClientContext:(BOOL)isFromClientContext {
    // no need to process background from client,
    //  since it's already processed by 'ccBackground'
    if (isFromClientContext) {
        return;
    }

    ADJSingleThreadExecutor *_Nullable clientExecutor = self.clientExecutorWeak;
    if (clientExecutor == nil) {
        [self.logger error:@"Cannot process Background without a reference to"
            " client executor"];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processBackground];
    }];
}

#pragma mark Internal Methods
- (void)processKeepAlivePing {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage =
        self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger error:@"Cannot process Keep Alive Ping"
            " without a reference to storage"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot process Keep Alive Ping"
            " without a reference to clock"];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
        [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger error:@"Cannot process Keep Alive Ping"
            " without a valid now timestamp"];
        return;
    }

    ADJMeasurementSessionStateData *_Nonnull currentMeasurementSessionStateData =
        [measurementSessionStateStorage readOnlyStoredDataValue];
    ADJValueWO<ADJMeasurementSessionData *> *_Nonnull changedMeasurementSessionDataWO =
        [[ADJValueWO alloc] init];

    [self.measurementSessionState keepAlivePingedWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
                                           changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
                                     nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    [self
        handleJustChangedMeasurementSessionDataSideEffectWithCurrentMeasurementSessionData:
            currentMeasurementSessionStateData
        changedMeasurementSessionData:changedMeasurementSessionDataWO.changedValue
        measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)processForegroundWithSource:(nonnull NSString *)source {
    BOOL canMeasurementSessionBecomeActive =
        [self.measurementSessionState canMeasurementSessionBecomeActiveWhenAppWentToTheForeground];

    if (canMeasurementSessionBecomeActive) {
        [self changeToActiveSessionWithSource:source];
    }
}

- (void)processBackground {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger error:@"Cannot process Background"
            " without a reference to storage"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot process Background"
            " without a reference to clock"];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
        [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger error:@"Cannot process Background"
            " without a valid now timestamp"];
        return;
    }

    ADJMeasurementSessionStateData *_Nullable currentMeasurementSessionStateData =
        [measurementSessionStateStorage readOnlyStoredDataValue];
    ADJValueWO<ADJMeasurementSessionData *> *_Nonnull changedMeasurementSessionDataWO =
        [[ADJValueWO alloc] init];

    [self.measurementSessionState
        appWentToTheBackgroundWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
        changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
        nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    [self
        handleJustChangedMeasurementSessionDataSideEffectWithCurrentMeasurementSessionData:
            currentMeasurementSessionStateData
        changedMeasurementSessionData:changedMeasurementSessionDataWO.changedValue
        measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)
    handleJustChangedMeasurementSessionDataSideEffectWithCurrentMeasurementSessionData:
        (nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
    changedMeasurementSessionData:(nullable ADJMeasurementSessionData *)changedMeasurementSessionData
    measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
{
    [self handleSideEffectsWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
                                  packageSessionData:nil
                                  sdkStartStateEvent:nil
                               changedMeasurementSessionData:changedMeasurementSessionData
                              measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)changeToActiveSessionWithSource:(nonnull NSString *)source {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger error:@"Cannot process Change To Active Session"
            " without a reference to storage"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot process Change To Active Session"
            " without a reference to clock"];
        return;
    }

    ADJMeasurementSessionStateData *_Nullable currentMeasurementSessionStateData =
        [measurementSessionStateStorage readOnlyStoredDataValue];

    [self publishWillFirstMeasurementSessionStartHappenWithCurrentMeasurementSessionStateData:
        currentMeasurementSessionStateData];

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
        [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger error:@"Cannot process Change To Active Session"
            " without a valid now timestamp"];
        return;
    }

    if (self.overwriteFirstMeasurementSessionIntervalMilli != nil) {
        [self.logger debug:@"Trying to overwrite First Sdk Session Interval by %@",
            self.overwriteFirstMeasurementSessionIntervalMilli];
        ADJMeasurementSessionData *_Nullable currentMeasurementSessionData = currentMeasurementSessionStateData.measurementSessionData;
        if (currentMeasurementSessionData != nil) {
            ADJTimestampMilli *_Nonnull overwrittenNowTimestamp =
                [currentMeasurementSessionData.lastActivityTimestampMilli
                    generateTimestampWithAddedTimeLength:self.overwriteFirstMeasurementSessionIntervalMilli];
            [self.logger debug:@"Now timestamp overwritten from %@ to %@"
                " from last activity timestamp %@",
                nonMonotonicNowTimestampMilli, overwrittenNowTimestamp,
                currentMeasurementSessionData.lastActivityTimestampMilli];
            nonMonotonicNowTimestampMilli = overwrittenNowTimestamp;
        } else {
            [self.logger debug:@"Cannot overwrite First Sdk Session Interval"
                " without last activity timestamp"];
        }

        self.overwriteFirstMeasurementSessionIntervalMilli = nil;
    }

    NSLog(@"tormv nonMonotonicNowTimestampMilli %@", nonMonotonicNowTimestampMilli);

    ADJValueWO<NSString *> *_Nonnull sdkStartStateEventWO = [[ADJValueWO alloc] init];
    ADJValueWO<ADJMeasurementSessionData *> *_Nonnull changedMeasurementSessionDataWO =
        [[ADJValueWO alloc] init];
    ADJValueWO<ADJPackageSessionData *> *_Nonnull packageSessionDataWO =
        [[ADJValueWO alloc] init];

    BOOL changedToActiveSession  =
        [self.measurementSessionState
            changeToActiveSessionWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
            sdkStartStateEventWO:sdkStartStateEventWO
            changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
            packageSessionDataWO:packageSessionDataWO
            nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli
            source:source];

    if (! changedToActiveSession) {
        [self.logger error:@"Unable to change to Active Session"];
        return;
    }

    [self handleSideEffectsWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
                                  packageSessionData:packageSessionDataWO.changedValue
                                  sdkStartStateEvent:sdkStartStateEventWO.changedValue
                               changedMeasurementSessionData:changedMeasurementSessionDataWO.changedValue
                              measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)
    handleSideEffectsWithCurrentMeasurementSessionData:
        (nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
    packageSessionData:(nullable ADJPackageSessionData *)packageSessionData
    sdkStartStateEvent:(nullable NSString *)sdkStartStateEvent
    changedMeasurementSessionData:(nullable ADJMeasurementSessionData *)changedMeasurementSessionData
    measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
{
    ADJMeasurementSessionStateStorageAction *_Nullable updateMeasurementSessionStateStorageAction = nil;
    if (changedMeasurementSessionData != nil) {
        ADJMeasurementSessionStateData *_Nonnull changedMeasurementSessionStateData =
            //[[ADJMeasurementSessionStateData alloc] initWithUuid:currentMeasurementSessionStateData.uuid
            [[ADJMeasurementSessionStateData alloc] initWithMeasurementSessionData:changedMeasurementSessionData];
        updateMeasurementSessionStateStorageAction =
            [[ADJMeasurementSessionStateStorageAction alloc]
                initWithMeasurementSessionStateStorage:measurementSessionStateStorage
                measurementSessionStateData:changedMeasurementSessionStateData];
    }

    if (packageSessionData != nil) {
        [self buildAndSendSesionPackageWithData:packageSessionData
             updateMeasurementSessionStateStorageAction:updateMeasurementSessionStateStorageAction];
    } else {
        [ADJUtilSys finalizeAtRuntime:updateMeasurementSessionStateStorageAction];
    }

    if (sdkStartStateEvent != nil) {
        [self.measurementSessionStartPublisher notifySubscribersWithSubscriberBlock:
            ^(id<ADJMeasurementSessionStartSubscriber> _Nonnull subscriber)
        {
            [subscriber ccMeasurementSessionStartWithStatus:sdkStartStateEvent];
        }];
    }
}

- (void)publishWillFirstMeasurementSessionStartHappenWithCurrentMeasurementSessionStateData:
    (nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
{
    if (self.measurementSessionState.hasFirstMeasurementSessionStartHappened) {
        return;
    }

    BOOL hasFirstSessionHappened = currentMeasurementSessionStateData.measurementSessionData != nil;

    [self.preFirstMeasurementSessionStartPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJPreFirstMeasurementSessionStartSubscriber> _Nonnull subscriber)
    {
        [subscriber ccPreFirstMeasurementSessionStart:hasFirstSessionHappened];
    }];
}

- (void)
    buildAndSendSesionPackageWithData:(nonnull ADJPackageSessionData *)packageSessionData
    updateMeasurementSessionStateStorageAction:
        (nullable ADJMeasurementSessionStateStorageAction *)updateMeasurementSessionStateStorageAction
{
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot Build and Send Session Package"
            " without a reference to sdk package builder"];
        [ADJUtilSys finalizeAtRuntime:updateMeasurementSessionStateStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger error:@"Cannot Build and Send Session Package"
            " without a reference to Main Queue Controller"];
        [ADJUtilSys finalizeAtRuntime:updateMeasurementSessionStateStorageAction];
        return;
    }

    ADJSessionPackageData *_Nonnull sessionPackageData =
        [sdkPackageBuilder buildSessionPackageWithDataToOverwrite:packageSessionData];

    [mainQueueController addSessionPackageToSendWithData:sessionPackageData
                                     sqliteStorageAction:updateMeasurementSessionStateStorageAction];
}

- (void)sdkBecameActive {
    BOOL canMeasurementSessionBecomeActive =
        [self.measurementSessionState canMeasurementSessionBecomeActiveWhenSdkBecameActive];

    if (canMeasurementSessionBecomeActive) {
        [self changeToActiveSessionWithSource:@"SdkBecameActive"];
    }
}

- (void)sdkBecameNotActive {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger error:@"Cannot process Sdk Became Not Active"
            " without a reference to storage"];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot process Sdk Became Not Active"
            " without a reference to clock"];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
        [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger error:@"Cannot process Sdk Became Not Active"
            " without a valid now timestamp"];
        return;
    }

    ADJMeasurementSessionStateData *_Nonnull currentMeasurementSessionStateData =
        [measurementSessionStateStorage readOnlyStoredDataValue];

    ADJValueWO<ADJMeasurementSessionData *> *_Nonnull changedMeasurementSessionDataWO =
        [[ADJValueWO alloc] init];

    [self.measurementSessionState
        sdkBecameNotActiveWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
        changedMeasurementSessionDataWO:changedMeasurementSessionDataWO
        nonMonotonicNowTimestampMilli:nonMonotonicNowTimestampMilli];

    [self
        handleJustChangedMeasurementSessionDataSideEffectWithCurrentMeasurementSessionData:
            currentMeasurementSessionStateData
        changedMeasurementSessionData:changedMeasurementSessionDataWO.changedValue
        measurementSessionStateStorage:measurementSessionStateStorage];
}

@end
