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
#import "ADJMeasurementConsentController.h"

@interface ADJClientActionController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJClientActionStorage *storage;
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
@property (nullable, readwrite, weak, nonatomic) id<ADJClientActionsAPIPostSdkStart> clientActionsPostSdkStartWeak;

@end

@implementation ADJClientActionController

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          clientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                        clock:(nonnull ADJClock *)clock
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ClientActionController"];
    _storage = clientActionStorage;
    _clock = clock;
    _clientActionsPostSdkStartWeak = nil;

    return self;
}

#pragma mark Public API
- (void)ccSetDependencyClientActionsPostSdkStart:(id<ADJClientActionsAPIPostSdkStart>)clientActionsPostSdkStart {
    self.clientActionsPostSdkStartWeak = clientActionsPostSdkStart;
}

- (nonnull id<ADJClientActionsAPI>)ccClientMeasurementActions {
    return self.clientActionsPostSdkStartWeak ?: self;
}

- (void)ccPreSdkStartWithPreFirstSession:(BOOL)isPreFirstSession
                            postSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)postSdkStart
{
    self.clientActionsPostSdkStartWeak = postSdkStart;
    [self ccProcessClientActionsWithPreFirstSession:isPreFirstSession
                                       postSdkStart:postSdkStart];
}

- (void)ccPostSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)postSdkStart {
    [self ccProcessClientActionsWithPreFirstSession:NO
                                       postSdkStart:postSdkStart];
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

- (void)ccTrackMeasurementConsent:(ADJClientMeasurementConsentData *)consentData {
    [self ccSaveClientActionWithIoInjectable:consentData
                       clientActionHandlerId:ADJMeasurementConsentControllerClientActionHandlerId];
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
    ADJResult<ADJTimestampMilli *> *_Nonnull nowResult = [self.clock nonMonotonicNowTimestamp];
    if (nowResult.fail != nil) {
        [self.logger debugDev:@"Cannot enqueue client action without a valid now timestamp"
                   resultFail:nowResult.fail
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
                                                      nowTimestamp:nowResult.value
                                                     ioDataBuilder:ioDataBuilder];

    [self.storage enqueueElementToLast:clientActionData
                   sqliteStorageAction:nil];
}

- (void)
    ccProcessClientActionsWithPreFirstSession:(BOOL)isPreFirstSession
    postSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)postSdkStart
{
    NSArray<ADJNonNegativeInt *> *_Nonnull elementPositionList =
        [self.storage copySortedElementPositionList];

    [self.logger debugDev:@"Trying to process client actions"
                     key1:@"count"
             stringValue1:[ADJUtilF uIntegerFormat:elementPositionList.count]
                     key2:@"is pre first session"
             stringValue2:[ADJUtilF boolFormat:isPreFirstSession]];

    for (ADJNonNegativeInt *_Nonnull elementPosition in elementPositionList) {
        ADJClientActionData *_Nullable clientActionData =
            [self.storage elementByPosition:elementPosition];
        if (clientActionData == nil) {
            [self.logger debugDev:@"Cannot process client action from queue with queue id"
                              key:@"elementPosition"
                      stringValue:elementPosition.description
                        issueType:ADJIssueStorageIo];
            continue;
        }

        id<ADJClientActionHandler> _Nullable clientActionHandler =
            [postSdkStart ccHandlerById:clientActionData.clientActionHandlerId];

        if (clientActionHandler == nil) {
            [self.logger debugDev:@"Cannot process client action with handler id"
                              key:@"clientActionHandlerId"
                      stringValue:clientActionData.clientActionHandlerId.stringValue
                        issueType:ADJIssueStorageIo];
            continue;
        }

        if (isPreFirstSession) {
            BOOL canHandleClientAction =
                [clientActionHandler ccCanHandlePreFirstSessionClientAction];

            if (! canHandleClientAction) {
                [self.logger debugDev:@"Client Actino Handler cannot proccess pre first session"
                                  key:@"clientActionHandlerId"
                          stringValue:clientActionData.clientActionHandlerId.stringValue];
                continue;
            }
        }

        ADJClientActionRemoveStorageAction *_Nonnull clientActionRemoveStorageAction =
            [[ADJClientActionRemoveStorageAction alloc]
             initWithClientActionStorage:self.storage
             elementPosition:elementPosition];

        [clientActionHandler ccHandleClientActionWithIoInjectedData:clientActionData.ioData
                                                       apiTimestamp:clientActionData.apiTimestamp
                                                removeStorageAction:clientActionRemoveStorageAction];
    }
}

@end
