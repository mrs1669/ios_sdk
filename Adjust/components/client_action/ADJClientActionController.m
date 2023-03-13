//
//  ADJClientActionController.m
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientActionController.h"

#import "ADJUtilF.h"
#import "ADJClientActionIoDataInjectable.h"
#import "ADJIoDataBuilder.h"
#import "ADJClientActionHandler.h"
#import "ADJAdRevenueController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"
#import "ADJClientActionRemoveStorageAction.h"
#import "ADJLaunchedDeeplinkController.h"
#import "ADJBillingSubscriptionController.h"
#import "ADJEventController.h"
#import "ADJPushTokenController.h"
#import "ADJClientActionRemoveStorageAction.h"
#import "ADJThirdPartySharingController.h"

@interface ADJClientActionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJClientActionStorage *clientActionStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nullable, readwrite, weak, nonatomic) id<ADJClientActionsAPI> postSdkStartClientActionsWeak;
@property (readwrite, assign, nonatomic) BOOL canHandleActionsByPostSdkStartHandler;
@end

@implementation ADJClientActionController

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          clientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                        clock:(nonnull ADJClock *)clock {

    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ClientActionController"];
    _clientActionStorageWeak = clientActionStorage;
    _clockWeak = clock;
    _postSdkStartClientActionsWeak = nil;
    _canHandleActionsByPostSdkStartHandler = NO;

    return self;
}

#pragma mark Public API

- (void)ccSetDependencyPostSdkStartClientActions:(id<ADJClientActionsAPI>)postSdkStartClientActions {
    self.postSdkStartClientActionsWeak = postSdkStartClientActions;
}

- (nonnull id<ADJClientActionsAPI>)ccClientMeasurementActions {
    id<ADJClientActionsAPI> _Nullable postSdkStartClientActions = self.postSdkStartClientActionsWeak;
    return (self.canHandleActionsByPostSdkStartHandler &&
            postSdkStartClientActions != nil) ? postSdkStartClientActions : self;
}

- (void)ccPreSdkStartWithPreFirstSession:(BOOL)isPreFirstSession {
    self.canHandleActionsByPostSdkStartHandler = YES;
    [self ccProcessClientActionsWithPreFirstSession:isPreFirstSession];
}

- (void)ccPostSdkStart {
    [self ccProcessClientActionsWithPreFirstSession:NO];
}

#pragma mark - ADJClientActionsAPI
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self ccSaveClientActionWithIoInjectable:clientAdRevenueData
                       clientActionHandlerId:ADJAdRevenueControllerClientActionHandlerId];
}

- (void)ccTrackBillingSubscriptionWithClientData:
    (nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
{
    [self ccSaveClientActionWithIoInjectable:clientBillingSubscriptionData
                        clientActionHandlerId:ADJBillingSubscriptionControllerClientActionHandlerId];
}

- (void)ccTrackLaunchedDeeplinkWithClientData:
    (nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData
{
    [self ccSaveClientActionWithIoInjectable:clientLaunchedDeeplinkData
                       clientActionHandlerId:ADJLaunchedDeeplinkClientActionHandlerId];
}

- (void)ccTrackEventWithClientData:
    (nonnull ADJClientEventData *)clientEventData
{
    [self ccSaveClientActionWithIoInjectable:clientEventData
                       clientActionHandlerId:ADJEventControllerClientActionHandlerId];
}

- (void)ccTrackPushTokenWithClientData:
    (nonnull ADJClientPushTokenData *)clientPushTokenData
{
    [self ccSaveClientActionWithIoInjectable:clientPushTokenData
                       clientActionHandlerId:ADJPushTokenControllerClientActionHandlerId];
}

- (void)ccTrackThirdPartySharingWithClientData:
    (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
{
    [self ccSaveClientActionWithIoInjectable:clientThirdPartySharingData
                       clientActionHandlerId:ADJThirdPartySharingControllerClientActionHandlerId];
}

- (void)ccAddGlobalCallbackParameterWithClientData:
    (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientAddGlobalCallbackParameterActionData
     clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:
    (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientRemoveGlobalCallbackParameterActionData
     clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccClearGlobalCallbackParametersWithClientData:
    (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientClearGlobalCallbackParametersActionData
     clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccAddGlobalPartnerParameterWithClientData:
    (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientAddGlobalPartnerParameterActionData
     clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:
    (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientRemoveGlobalPartnerParameterActionData
     clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

- (void)ccClearGlobalPartnerParametersWithClientData:
    (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData
{
    [self
     ccSaveClientActionWithIoInjectable:clientClearGlobalPartnerParametersActionData
     clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

#pragma mark Internal Methods
- (void)
    ccSaveClientActionWithIoInjectable:
        (nonnull id<ADJClientActionIoDataInjectable>)clientActionIoDataInjectable
    clientActionHandlerId:(nonnull NSString *)clientActionHandlerId
{
    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger debugDev:@"Cannot enqueue client action without a reference to clock"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJTimestampMilli *_Nullable nowTimestamp =
        [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nowTimestamp == nil) {
        [self.logger debugDev:@"Cannot enqueue client action without a valid now timestamp"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;
    if (clientActionStorage == nil) {
        [self.logger debugDev:@"Cannot enqueue client action without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    ADJIoDataBuilder *_Nonnull ioDataBuilder =
        [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:
         ADJClientActionDataMetadataTypeValue];

    [clientActionIoDataInjectable injectIntoClientActionIoDataBuilder:ioDataBuilder];

    ADJClientActionData *_Nonnull clientActionData =
        [[ADJClientActionData alloc] initWithClientActionHandlerId:
         [[ADJNonEmptyString alloc] initWithConstStringValue:clientActionHandlerId]
                                                      nowTimestamp:nowTimestamp
                                                     ioDataBuilder:ioDataBuilder];

    [clientActionStorage enqueueElementToLast:clientActionData
                          sqliteStorageAction:nil];
}

- (void)ccProcessClientActionsWithPreFirstSession:(BOOL)isPreFirstSession {
    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;
    if (clientActionStorage == nil) {
        [self.logger debugDev:@"Cannot process client actions without a reference to storage"
                    issueType:ADJIssueWeakReference];
        return;
    }

    NSArray<ADJNonNegativeInt *> *_Nonnull elementPositionList =
        [clientActionStorage copySortedElementPositionList];

    [self.logger debugDev:@"Trying to process client actions"
                     key1:@"count"
                   value1:[ADJUtilF uIntegerFormat:elementPositionList.count]
                     key2:@"is pre first session"
                   value2:[ADJUtilF boolFormat:isPreFirstSession]];

    id<ADJClientActionsAPI> postSdkStartClientActions = self.postSdkStartClientActionsWeak;
    if (postSdkStartClientActions == nil) {
        [self.logger debugDev:
         @"Cannot try to start sdk without a reference to postSdkStartClientActions"
                    issueType:ADJIssueWeakReference];
        return;
    }


    for (ADJNonNegativeInt *_Nonnull elementPosition in elementPositionList) {
        ADJClientActionData *_Nullable clientActionData =
            [clientActionStorage elementByPosition:elementPosition];
        if (clientActionData == nil) {
            [self.logger debugDev:@"Cannot process client action from queue with queue id"
                              key:@"elementPosition"
                            value:elementPosition.description
                        issueType:ADJIssueStorageIo];
            continue;
        }

        id<ADJClientActionHandler> _Nullable clientActionHandler =
            [postSdkStartClientActions ccHandlerById:clientActionData.clientActionHandlerId];

        if (clientActionHandler == nil) {
            [self.logger debugDev:@"Cannot process client action with handler id"
                              key:@"clientActionHandlerId"
                            value:clientActionData.clientActionHandlerId.stringValue
                        issueType:ADJIssueStorageIo];
            continue;
        }

        if (isPreFirstSession) {
            BOOL canHandleClientAction =
                [clientActionHandler ccCanHandlePreFirstSessionClientAction];

            if (! canHandleClientAction) {
                [self.logger debugDev:@"Client Actino Handler cannot proccess pre first session"
                                  key:@"clientActionHandlerId"
                                value:clientActionData.clientActionHandlerId.stringValue];
                continue;
            }
        }

        ADJClientActionRemoveStorageAction *_Nonnull clientActionRemoveStorageAction =
            [[ADJClientActionRemoveStorageAction alloc]
             initWithClientActionStorage:clientActionStorage
             elementPosition:elementPosition];

        [clientActionHandler ccHandleClientActionWithIoInjectedData:clientActionData.ioData
                                                       apiTimestamp:clientActionData.apiTimestamp
                                                removeStorageAction:clientActionRemoveStorageAction];
    }
}

@end


