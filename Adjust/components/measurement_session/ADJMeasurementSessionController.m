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
@property (nullable, readwrite, strong, nonatomic)ADJTimeLengthMilli *overwriteFirstMeasurementSessionIntervalMilli;
@property (nullable, readonly, weak, nonatomic) ADJSingleThreadExecutor *clientExecutorWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMeasurementSessionStateStorage *measurementSessionStateStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionState *measurementSessionState;

@end

@implementation ADJMeasurementSessionController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
           minMeasurementSessionIntervalMilli:(nonnull ADJTimeLengthMilli *)minMeasurementSessionIntervalMilli
overwriteFirstMeasurementSessionIntervalMilli:(nullable ADJTimeLengthMilli *)overwriteFirstMeasurementSessionIntervalMilli
                               clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
               measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
                                        clock:(nonnull ADJClock *)clock
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry {

    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementSessionController"];
    _overwriteFirstMeasurementSessionIntervalMilli = overwriteFirstMeasurementSessionIntervalMilli;
    _clientExecutorWeak = clientExecutor;
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _measurementSessionStateStorageWeak = measurementSessionStateStorage;
    _mainQueueControllerWeak = mainQueueController;
    _clockWeak = clock;

    _preFirstMeasurementSessionStartPublisher = [[ADJPreFirstMeasurementSessionStartPublisher alloc] init];
    [pubRegistry addPublisher:_preFirstMeasurementSessionStartPublisher];
    _measurementSessionStartPublisher = [[ADJMeasurementSessionStartPublisher alloc] init];
    [pubRegistry addPublisher:_measurementSessionStartPublisher];

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

- (nullable ADJMeasurementSessionStateData *)currentMeasurementSessionStateDataWithLogger:(nonnull ADJLogger *)logger {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;

    if (measurementSessionStateStorage == nil) {
        [self.logger debugDev:
         @"Cannot get current sdk session state data without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return nil;
    }

    return [measurementSessionStateStorage readOnlyStoredDataValue];
}

#pragma mark - ADJSdkActiveSubscriber
- (void)ccSdkActiveWithStatus:(nonnull NSString *)status {
    [self.logger debugDev:@"Handling ccSdkActiveState with"
                      key:@"status"
                    value:status];

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
        [self.logger debugDev:
         @"Cannot process Keep Alive Ping without a reference to client executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processKeepAlivePing];
    } source:@"keep alive ping"];
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
        [self.logger debugDev:
         @"Cannot process Foreground without a reference to client executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processForegroundWithSource:@"onForeground"];
    } source:@"foreground"];
}

- (void)onBackgroundWithIsFromClientContext:(BOOL)isFromClientContext {
    // no need to process background from client,
    //  since it's already processed by 'ccBackground'
    if (isFromClientContext) {
        return;
    }

    ADJSingleThreadExecutor *_Nullable clientExecutor = self.clientExecutorWeak;
    if (clientExecutor == nil) {
        [self.logger debugDev:
         @"Cannot process Background without a reference to client executor"
                    issueType:ADJIssueWeakReference];
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processBackground];
    } source:@"background"];
}

#pragma mark Internal Methods
- (void)processKeepAlivePing {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage =
    self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger debugDev:@"Cannot process Keep Alive Ping without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot process Keep Alive Ping without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger debugDev:@"Cannot process Keep Alive Ping without a valid now timestamp"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJMeasurementSessionStateData *_Nonnull currentMeasurementSessionStateData =
    [measurementSessionStateStorage readOnlyStoredDataValue];
    ADJValueWO<ADJMeasurementSessionData *> *_Nonnull changedMeasurementSessionDataWO =
    [[ADJValueWO alloc] init];

    [self.measurementSessionState
     keepAlivePingedWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
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
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage =
    self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger debugDev:@"Cannot process Background without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot process Background without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger debugDev:@"Cannot process Background without a valid now timestamp"
                    issueType:ADJIssueWeakReference];
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

- (void)handleJustChangedMeasurementSessionDataSideEffectWithCurrentMeasurementSessionData:
(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                                             changedMeasurementSessionData:(nullable ADJMeasurementSessionData *)changedMeasurementSessionData
                                                            measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage {
    [self handleSideEffectsWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
                                          packageSessionData:nil
                                          sdkStartStateEvent:nil
                               changedMeasurementSessionData:changedMeasurementSessionData
                              measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)changeToActiveSessionWithSource:(nonnull NSString *)source {
    ADJMeasurementSessionStateStorage *_Nullable measurementSessionStateStorage = self.measurementSessionStateStorageWeak;
    if (measurementSessionStateStorage == nil) {
        [self.logger debugDev:
         @"Cannot process Change To Active Session without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:
         @"Cannot process Change To Active Session without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJMeasurementSessionStateData *_Nullable currentMeasurementSessionStateData =
    [measurementSessionStateStorage readOnlyStoredDataValue];

    [self publishWillFirstMeasurementSessionStartHappenWithCurrentMeasurementSessionStateData:
     currentMeasurementSessionStateData];

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger debugDev:
         @"Cannot process Change To Active Session without a valid now timestamp"
                    issueType:ADJIssueExternalApi];
        return;
    }

    if (self.overwriteFirstMeasurementSessionIntervalMilli != nil) {
        [self.logger debugDev:@"Trying to overwrite First Sdk Session Interval"
                          key:@"overwriteFirstMeasurementSessionInterval"
                        value:self.overwriteFirstMeasurementSessionIntervalMilli.description];

        ADJMeasurementSessionData *_Nullable currentMeasurementSessionData =
        currentMeasurementSessionStateData.measurementSessionData;
        if (currentMeasurementSessionData != nil) {
            ADJTimestampMilli *_Nonnull overwrittenNowTimestamp =
            [currentMeasurementSessionData.lastActivityTimestampMilli
             generateTimestampWithAddedTimeLength:
                 self.overwriteFirstMeasurementSessionIntervalMilli];
            [self.logger debugDev:@"Now timestamp overwritten"
                    messageParams:
             [NSDictionary dictionaryWithObjectsAndKeys:
              nonMonotonicNowTimestampMilli.description, @"nowTimestamp",
              overwrittenNowTimestamp.description, @"overwrittenNowTimestamp",
              [currentMeasurementSessionData.lastActivityTimestampMilli description],
              @"lastActivityTimestamp", nil]];
            nonMonotonicNowTimestampMilli = overwrittenNowTimestamp;
        } else {
            [self.logger debugDev:
             @"Cannot overwrite First Sdk Session Interval without last activity timestamp"];
        }

        self.overwriteFirstMeasurementSessionIntervalMilli = nil;
    }

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
        [self.logger debugDev:@"Unable to change to Active Session"];
        return;
    }

    [self
     handleSideEffectsWithCurrentMeasurementSessionData:currentMeasurementSessionStateData
     packageSessionData:packageSessionDataWO.changedValue
     sdkStartStateEvent:sdkStartStateEventWO.changedValue
     changedMeasurementSessionData:changedMeasurementSessionDataWO.changedValue
     measurementSessionStateStorage:measurementSessionStateStorage];
}

- (void)handleSideEffectsWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                        packageSessionData:(nullable ADJPackageSessionData *)packageSessionData
                                        sdkStartStateEvent:(nullable NSString *)sdkStartStateEvent
                             changedMeasurementSessionData:(nullable ADJMeasurementSessionData *)changedMeasurementSessionData
                            measurementSessionStateStorage:(nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage {
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
(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData {
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

- (void)buildAndSendSesionPackageWithData:(nonnull ADJPackageSessionData *)packageSessionData
updateMeasurementSessionStateStorageAction:(nullable ADJMeasurementSessionStateStorageAction *)updateMeasurementSessionStateStorageAction {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot Build and Send Session Package without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];
        [ADJUtilSys finalizeAtRuntime:updateMeasurementSessionStateStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Build and Send Session Package without a reference to Main Queue Controller"
                    issueType:ADJIssueWeakReference];
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
        [self.logger debugDev:
         @"Cannot process Sdk Became Not Active without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot process Sdk Became Not Active without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger debugDev:@"Cannot process Sdk Became Not Active without a valid now timestamp"
                    issueType:ADJIssueExternalApi];
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



