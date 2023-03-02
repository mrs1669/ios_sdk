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

#pragma mark Fields
@interface ADJMeasurementSessionController ()
#pragma mark - Injected dependencies
@property (nullable, readwrite, strong, nonatomic)
    ADJTimeLengthMilli *overwriteFirstMeasurementSessionInterval;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic)
    ADJClientActionController *clientActionControllerWeak;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementSessionStateStorage *storage;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
    ADJMeasurementSessionState *measurementSessionState;

@end

@implementation ADJMeasurementSessionController

#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    minMeasurementSessionInterval:
        (nonnull ADJTimeLengthMilli *)minMeasurementSessionInterval
    overwriteFirstMeasurementSessionInterval:
        (nullable ADJTimeLengthMilli *)overwriteFirstMeasurementSessionInterval
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    measurementSessionStateStorage:
        (nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    clock:(nonnull ADJClock *)clock
    clientActionController:(nonnull ADJClientActionController *)clientActionController
{
    self = [super initWithLoggerFactory:loggerFactory source:@"MeasurementSessionController"];
    _overwriteFirstMeasurementSessionInterval = overwriteFirstMeasurementSessionInterval;
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _mainQueueControllerWeak = mainQueueController;
    _clientActionControllerWeak = clientActionController;
    _clientExecutor = clientExecutor;
    _storage = measurementSessionStateStorage;
    _clock = clock;

    _measurementSessionState =
        [[ADJMeasurementSessionState alloc]
         initWithLoggerFactory:loggerFactory
         initialMeasurementSessionStateData:
             [measurementSessionStateStorage readOnlyStoredDataValue]
         overwriteFirstSdkSessionInterval:overwriteFirstMeasurementSessionInterval
         minMeasurementSessionInterval:minMeasurementSessionInterval];

    return self;
}

#pragma mark Public API
- (BOOL)ccTryStartSdk {
    ADJTimestampMilli *_Nullable nonMonotonicNowTimestamp =
        [self ccNonMonotonicNowTimestampWithSource:@"try start sdk"];
    if (nonMonotonicNowTimestamp == nil) { return NO; }

    ADJClientActionController *_Nullable clientActionController = self.clientActionControllerWeak;
    if (clientActionController == nil) {
        [self.logger debugDev:
         @"Cannot try to start sdk without a reference to clientActionController"
                    issueType:ADJIssueWeakReference];
        return NO;
    }

    ADJMeasurementSessionStateOutputData *_Nullable measurementSessionOutput =
        [self.measurementSessionState
         sdkStartWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp];
    if (measurementSessionOutput == nil) { return NO; }

    // pre sdk start
    ADJMeasurementSessionStateData *_Nonnull preSdkStartStateData =
        [self.storage readOnlyStoredDataValue];

    BOOL isPreFirstSession = preSdkStartStateData.measurementSessionData == nil;

    [clientActionController ccPreSdkStartWithPreFirstSession:isPreFirstSession];

    // sdk start
    [self ccHandleMeasurementSessionOutput:measurementSessionOutput];

    // post sdk start
    [clientActionController ccPostSdkStart];

    return YES;
}

#pragma mark - ADJMeasurementLifecycleSubscriber
- (void)ccDidResumeMeasurementWithIsFirst:(BOOL)isFirstMeasurement {
    if (isFirstMeasurement) { return; }

    ADJTimestampMilli *_Nullable nonMonotonicNowTimestamp =
        [self ccNonMonotonicNowTimestampWithSource:@"resume measurement"];
    if (nonMonotonicNowTimestamp == nil) { return; }

    ADJMeasurementSessionStateOutputData *_Nullable measurementSessionOutput =
        [self.measurementSessionState resumeMeasurementWithNowTimestamp:nonMonotonicNowTimestamp];

    [self ccHandleMeasurementSessionOutput:measurementSessionOutput];
}
- (void)ccDidPauseMeasurement {
    ADJTimestampMilli *_Nullable nonMonotonicNowTimestamp =
        [self ccNonMonotonicNowTimestampWithSource:@"pause measurement"];
    if (nonMonotonicNowTimestamp == nil) { return; }

    ADJMeasurementSessionStateOutputData *_Nullable measurementSessionOutput =
        [self.measurementSessionState pauseMeasurementWithNowTimestamp:nonMonotonicNowTimestamp];

    [self ccHandleMeasurementSessionOutput:measurementSessionOutput];
}

#pragma mark - ADJKeepAlivePingPublisher
- (void)didPingKeepAliveInActiveSession {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf ccKeepAlivePing];

    } source:@"didPingKeepAliveInActiveSession"];
}

#pragma mark Internal Methods
- (nullable ADJTimestampMilli *)ccNonMonotonicNowTimestampWithSource:(nonnull NSString *)source {
    ADJTimestampMilli *_Nullable nonMonotonicNowTimestampMilli =
        [self.clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nonMonotonicNowTimestampMilli == nil) {
        [self.logger debugDev:@"Cannot obtain a valid now timestamp"
                         from:source
                    issueType:ADJIssueExternalApi];
        return nil;
    }

    return nonMonotonicNowTimestampMilli;
}

- (void)ccHandleMeasurementSessionOutput:
    (nonnull ADJMeasurementSessionStateOutputData *)measurementSessionOutput
{
    ADJMeasurementSessionStateStorageAction *_Nullable updateStorageAction =
        [self ccHandleChangedMeasurementStateData:measurementSessionOutput.changedStateData];

    BOOL sendPackage = [self ccHandleSessionPackage:measurementSessionOutput.packageSessionData
                                updateStorageAction:updateStorageAction];

    if (! sendPackage) {
        [ADJUtilSys finalizeAtRuntime:updateStorageAction];
    }
}
- (nullable ADJMeasurementSessionStateStorageAction *)ccHandleChangedMeasurementStateData:
    (nullable ADJMeasurementSessionStateData *)changedMeasurementStateData
{
    if (changedMeasurementStateData == nil) { return nil; }

    return [[ADJMeasurementSessionStateStorageAction alloc]
            initWithMeasurementSessionStateStorage:self.storage
            measurementSessionStateData:changedMeasurementStateData];
}
- (BOOL)
    ccHandleSessionPackage:(nullable ADJPackageSessionData *)packageSessionData
    updateStorageAction:(nullable ADJMeasurementSessionStateStorageAction *)updateStorageAction
{
    if (packageSessionData == nil) { return NO; }

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot handle Session Package without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];
        return NO;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot handle Session Package without a reference to Main Queue Controller"
                    issueType:ADJIssueWeakReference];
        return NO;
    }

    ADJSessionPackageData *_Nonnull sessionPackageData =
        [sdkPackageBuilder buildSessionPackageWithDataToOverwrite:packageSessionData];

    [mainQueueController addSessionPackageToSendWithData:sessionPackageData
                                     sqliteStorageAction:updateStorageAction];

    return YES;
}

- (void)ccKeepAlivePing {
    ADJTimestampMilli *_Nullable nonMonotonicNowTimestamp =
        [self ccNonMonotonicNowTimestampWithSource:@"keep alive ping"];
    if (nonMonotonicNowTimestamp == nil) { return; }

    ADJMeasurementSessionStateOutputData *_Nullable measurementSessionOutput =
        [self.measurementSessionState
         keepAlivePingWithNonMonotonicNowTimestamp:nonMonotonicNowTimestamp];

    [self ccHandleMeasurementSessionOutput:measurementSessionOutput];
}

@end
