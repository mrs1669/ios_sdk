//
//  ADJEventController.m
//  Adjust
//
//  Created by Pedro S. on 16.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJEventController.h"

#import "ADJEventDeduplicationController.h"
#import "ADJUtilSys.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJEventControllerClientActionHandlerId = @"EventController";

@interface ADJEventController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJEventStateStorage *eventStateStorageWeak;
@property (nullable, readonly, weak, nonatomic)
ADJMainQueueController *mainQueueControllerWeak;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJEventDeduplicationController *eventDeduplicationController;

@end

@implementation ADJEventController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                            sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
                            eventStateStorage:(nonnull ADJEventStateStorage *)eventStateStorage
                    eventDeduplicationStorage:(nonnull ADJEventDeduplicationStorage *)eventDeduplicationStorage
                          mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
                maxCapacityEventDeduplication:(nonnull ADJNonNegativeInt *)maxCapacityEventDeduplication {
    self = [super initWithLoggerFactory:loggerFactory source:@"EventController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _eventStateStorageWeak = eventStateStorage;
    _mainQueueControllerWeak = mainQueueController;

    _eventDeduplicationController = [[ADJEventDeduplicationController alloc]
                                     initWithLoggerFactory:loggerFactory
                                     eventDeduplicationStorage:eventDeduplicationStorage
                                     maxCapacityEventDeduplication:maxCapacityEventDeduplication];

    return self;
}

#pragma mark Public API
- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData {
    [self trackEventWithClientData:clientEventData
                      apiTimestamp:nil
   clientActionRemoveStorageAction:nil];
}

#pragma mark - ADJClientActionHandler
- (BOOL)ccCanHandlePreFirstSessionClientAction {
    return NO;
}

- (void)
    ccHandleClientActionWithClientActionIoInjectedData:
        (nonnull ADJIoData *)clientActionIoInjectedData
    apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
    clientActionRemoveStorageAction:
        (nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction
{
    ADJClientEventData *_Nullable clientEventData =
    [ADJClientEventData
     instanceFromClientActionInjectedIoDataWithData:clientActionIoInjectedData
     logger:self.logger];

    if (clientEventData == nil) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self trackEventWithClientData:clientEventData
                      apiTimestamp:apiTimestamp
   clientActionRemoveStorageAction:clientActionRemoveStorageAction];
}

#pragma mark Internal Methods
- (void)
    trackEventWithClientData:(nonnull ADJClientEventData *)clientEventData
    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
    clientActionRemoveStorageAction:
        (nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction
{
    [self.logger debugDev:@"Trying to track event"
                      key:@"event token"
                value:clientEventData.eventId.stringValue];

    if (! [self canTrackEventWithDeduplicationId:clientEventData.deduplicationId]) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self incrementEventCount];

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger debugDev:
         @"Cannot Track Event Package without a reference to sdk package builder"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger debugDev:
         @"Cannot Track Event Package without a reference to main queue controller"
                    issueType:ADJIssueWeakReference];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJEventPackageData *_Nonnull eventPackageData =
        [sdkPackageBuilder buildEventPackageWithClientData:clientEventData
                                              apiTimestamp:apiTimestamp];

    [mainQueueController addEventPackageToSendWithData:eventPackageData
                                   sqliteStorageAction:clientActionRemoveStorageAction];
}

- (BOOL)canTrackEventWithDeduplicationId:(nullable ADJNonEmptyString *)deduplicationId {
    if (deduplicationId == nil) {
        return YES;
    }

    if ([self.eventDeduplicationController ccContainsDeduplicationId:deduplicationId]) {
        [self.logger infoClient:
         @"Event won't be tracked, since it has a previously used deduplication id"
                            key:@"deduplication id"
                          value:deduplicationId.stringValue];
        return NO;
    }

    ADJNonNegativeInt *_Nonnull newDeduplicationCount = [self.eventDeduplicationController ccAddDeduplicationId:deduplicationId];

    [self.logger debugDev:
     @"Saving deduplication id to avoid tracking an event with the same value in the future"
                      key:@"deduplication id"
                    value:deduplicationId.stringValue];

    return YES;
}

- (void)incrementEventCount {
    ADJEventStateStorage *_Nullable eventStateStorage = self.eventStateStorageWeak;
    if (eventStateStorage == nil) {
        [self.logger debugDev:@"Cannot increment event count without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJEventStateData *_Nonnull eventStateData = [eventStateStorage readOnlyStoredDataValue];

    ADJEventStateData *_Nonnull newEventStateData =
        [eventStateData generateIncrementedEventCountStateData];

    [eventStateStorage updateWithNewDataValue:newEventStateData];

    [self.logger debugDev:@"Event count incremented"
                      key:@"event count"
                    value:newEventStateData.eventCount.description];
}

@end



