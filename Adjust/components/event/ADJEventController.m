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
- (BOOL)ccCanHandleClientActionWithIsPreFirstSession:(BOOL)isPreFirstSession {
    // cannot handle pre first session
    return ! isPreFirstSession;
}

- (void)ccHandleClientActionWithClientActionIoInjectedData:(nonnull ADJIoData *)clientActionIoInjectedData
                                              apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                           clientActionRemoveStorageAction:(nonnull ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
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
- (void)trackEventWithClientData:(nonnull ADJClientEventData *)clientEventData
                    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp
 clientActionRemoveStorageAction:(nullable ADJSQLiteStorageActionBase *)clientActionRemoveStorageAction {
    [self.logger debug:@"Trying to track event with id: %@", clientEventData.eventId];

    if (! [self canTrackEventWithDeduplicationId:clientEventData.deduplicationId]) {
        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    [self incrementEventCount];

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot Track Event Package"
         " without a reference to sdk package builder"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger error:@"Cannot Track Event Package"
         " without a reference to main queue controller"];

        [ADJUtilSys finalizeAtRuntime:clientActionRemoveStorageAction];
        return;
    }

    ADJEventPackageData *_Nonnull eventPackageData = [sdkPackageBuilder buildEventPackageWithClientData:clientEventData
                                                                                           apiTimestamp:apiTimestamp];

    [mainQueueController addEventPackageToSendWithData:eventPackageData
                                   sqliteStorageAction:clientActionRemoveStorageAction];
}

- (BOOL)canTrackEventWithDeduplicationId:(nullable ADJNonEmptyString *)deduplicationId {
    if (deduplicationId == nil) {
        return YES;
    }

    if ([self.eventDeduplicationController ccContainsWithDeduplicationId:deduplicationId]) {
        [self.logger info:@"Event won't be tracked,"
         " since it has a previously used deduplication id: %@", deduplicationId];
        return NO;
    }

    ADJNonNegativeInt *_Nonnull newDeduplicationCount =
    [self.eventDeduplicationController ccAddWithDeduplicationId:deduplicationId];

    [self.logger info:@"Saving deduplication id %@ to avoid tracking an event"
     " with the same value in the future. Currently storing %@ ids",
     deduplicationId, newDeduplicationCount];

    return YES;
}

- (void)incrementEventCount {
    ADJEventStateStorage *_Nullable eventStateStorage = self.eventStateStorageWeak;
    if (eventStateStorage == nil) {
        [self.logger error:@"Cannot increment event count without a reference to storage"];
        return;
    }

    ADJEventStateData *_Nonnull eventStateData = [eventStateStorage readOnlyStoredDataValue];

    ADJEventStateData *_Nonnull newEventStateData =
    [eventStateData generateIncrementedEventCountStateData];

    [eventStateStorage updateWithNewDataValue:newEventStateData];

    [self.logger debug:@"Event count incremented to %@", newEventStateData.eventCount];
}

@end



