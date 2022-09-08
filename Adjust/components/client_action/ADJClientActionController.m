//
//  ADJClientActionController.m
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientActionController.h"

#import "ADJUtilF.h"
#import "ADJPostSdkInitRootController.h"
#import "ADJClientActionIoDataInjectable.h"
#import "ADJIoDataBuilder.h"
#import "ADJClientActionHandler.h"
#import "ADJAdRevenueController.h"
#import "ADJGlobalCallbackParametersController.h"
#import "ADJGlobalPartnerParametersController.h"
#import "ADJClientActionRemoveStorageAction.h"
/*
 #import "ADJBillingSubscriptionController.h"
 #import "ADJLaunchedDeeplinkController.h"
 */
#import "ADJEventController.h"
#import "ADJPushTokenController.h"
#import "ADJClientActionRemoveStorageAction.h"
/*
 #import "ADJThirdPartySharingController.h"
 */

@interface ADJClientActionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJClientActionStorage *clientActionStorageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nullable, readwrite, weak, nonatomic) ADJPostSdkInitRootController *postSdkInitRootControllerWeak;

@end

@implementation ADJClientActionController

#pragma mark Subscriptions and Dependencies

- (void)ccSetDependenciesAtSdkInitWithPostSdkInitRootController:(nonnull ADJPostSdkInitRootController *)postSdkInitRootController {
    self.postSdkInitRootControllerWeak = postSdkInitRootController;
}

- (void)ccSubscribeToPublishersWithPreFirstMeasurementSessionStartPublisher:(nonnull ADJPreFirstMeasurementSessionStartPublisher *)preFirstMeasurementSessionStartPublisher measurementSessionStartPublisher:(nonnull ADJMeasurementSessionStartPublisher *)measurementSessionStartPublisher {
    [preFirstMeasurementSessionStartPublisher addSubscriber:self];
    [measurementSessionStartPublisher addSubscriber:self];
}

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          clientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                        clock:(nonnull ADJClock *)clock {

    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"ClientActionController"];
    _clientActionStorageWeak = clientActionStorage;
    _clockWeak = clock;
    _postSdkInitRootControllerWeak = nil;

    return self;
}

#pragma mark Public API
#pragma mark - ADJPreFirstMeasurementSessionStartSubscriber
- (void)ccPreFirstMeasurementSessionStart:(BOOL)hasFirstSessionHappened {
    [self ccProcessClientActionsWithIsPreFirstSession:! hasFirstSessionHappened];
}

#pragma mark - ADJMeasurementSessionStartSubscriber
- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus {
    [self ccProcessClientActionsWithIsPreFirstSession:NO];
}

#pragma mark - ADJClientActionsAPI
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self ccSaveClientActionWithIoInjectable:clientAdRevenueData
                       clientActionHandlerId:ADJAdRevenueControllerClientActionHandlerId];
}
/*
- (void)ccTrackBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData {
    [self  ccSaveClientActionWithIoInjectable:clientBillingSubscriptionData
        clientActionHandlerId:ADJBillingSubscriptionControllerClientActionHandlerId];
}

- (void)ccTrackLaunchedDeeplinkWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData {
    [self ccSaveClientActionWithIoInjectable:clientLaunchedDeeplinkData
                       clientActionHandlerId:ADJLaunchedDeeplinkClientActionHandlerId];
}
*/

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData {
    [self ccSaveClientActionWithIoInjectable:clientEventData
                       clientActionHandlerId:ADJEventControllerClientActionHandlerId];
}

- (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData {
    [self ccSaveClientActionWithIoInjectable:clientPushTokenData
                       clientActionHandlerId:ADJPushTokenControllerClientActionHandlerId];
}

/*
 - (void)ccTrackThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
 {
 [self ccSaveClientActionWithIoInjectable:clientThirdPartySharingData
 clientActionHandlerId:ADJThirdPartySharingControllerClientActionHandlerId];
 }
 */

- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData {
    [self ccSaveClientActionWithIoInjectable:clientAddGlobalCallbackParameterActionData
                       clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData {
    [self ccSaveClientActionWithIoInjectable:clientRemoveGlobalCallbackParameterActionData
                       clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccClearGlobalCallbackParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData {
    [self ccSaveClientActionWithIoInjectable:clientClearGlobalCallbackParametersActionData
                       clientActionHandlerId:ADJGlobalCallbackParametersControllerClientActionHandlerId];
}

- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData {
    [self ccSaveClientActionWithIoInjectable:clientAddGlobalPartnerParameterActionData
                       clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData {
    [self ccSaveClientActionWithIoInjectable:clientRemoveGlobalPartnerParameterActionData
                       clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

- (void)ccClearGlobalPartnerParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData {
    [self ccSaveClientActionWithIoInjectable:clientClearGlobalPartnerParametersActionData
                       clientActionHandlerId:ADJGlobalPartnerParametersControllerClientActionHandlerId];
}

#pragma mark Internal Methods

- (void)ccSaveClientActionWithIoInjectable:(nonnull id<ADJClientActionIoDataInjectable>)clientActionIoDataInjectable
                     clientActionHandlerId:(nonnull NSString *)clientActionHandlerId
{
    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        [self.logger error:@"Cannot enqueue client action without a reference to clock"];
        return;
    }

    ADJTimestampMilli *_Nullable nowTimestamp = [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nowTimestamp == nil) {
        [self.logger error:@"Cannot enqueue client action without a valid now timestamp"];
        return;
    }

    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;
    if (clientActionStorage == nil) {
        [self.logger error:@"Cannot enqueue client action without a reference to storage"];
        return;
    }

    ADJIoDataBuilder *_Nonnull ioDataBuilder = [[ADJIoDataBuilder alloc] initWithMetadataTypeValue:
                                                ADJClientActionDataMetadataTypeValue];

    [clientActionIoDataInjectable injectIntoClientActionIoDataBuilder:ioDataBuilder];

    ADJClientActionData *_Nonnull clientActionData = [[ADJClientActionData alloc] initWithClientActionHandlerId:
                                                      [[ADJNonEmptyString alloc] initWithConstStringValue:clientActionHandlerId]
                                                                                                   nowTimestamp:nowTimestamp
                                                                                                  ioDataBuilder:ioDataBuilder];

    [clientActionStorage enqueueElementToLast:clientActionData
                          sqliteStorageAction:nil];
}

- (void)ccProcessClientActionsWithIsPreFirstSession:(BOOL)isPreFirstSession {
    ADJClientActionStorage *_Nullable clientActionStorage = self.clientActionStorageWeak;
    if (clientActionStorage == nil) {
        [self.logger error:@"Cannot process client actions without a reference to storage"];
        return;
    }

    ADJPostSdkInitRootController *_Nullable postSdkInitRootController =
    self.postSdkInitRootControllerWeak;
    if (postSdkInitRootController == nil) {
        [self.logger error:@"Cannot process client actions"
         " without a reference to post sdk init controller"];
        return;
    }

    NSArray<ADJNonNegativeInt *> *_Nonnull elementPositionList =
    [clientActionStorage copySortedElementPositionList];

    [self.logger debug:@"Trying to handle %@ client actions %@",
     [ADJUtilF uIntegerFormat:elementPositionList.count],
     isPreFirstSession ? @"before first session" : @"after first session"];

    for (ADJNonNegativeInt *_Nonnull elementPosition in elementPositionList) {
        ADJClientActionData *_Nullable clientActionData =
        [clientActionStorage elementByPosition:elementPosition];
        if (clientActionData == nil) {
            [self.logger error:@"Cannot process client action from queue with queue id: %@",
             elementPosition];
            continue;
        }

        id<ADJClientActionHandler> _Nullable clientActionHandler =
        [self clientActionHandlerWithId:clientActionData.clientActionHandlerId
              postSdkInitRootController:postSdkInitRootController];
        if (clientActionHandler == nil) {
            [self.logger error:@"Cannot process client action with handler id: %@",
             clientActionData.clientActionHandlerId];
            continue;
        }

        BOOL canHandleClientAction =
        [clientActionHandler ccCanHandleClientActionWithIsPreFirstSession:isPreFirstSession];
        if (! canHandleClientAction) {
            [self.logger debug:@"Cannot handle client action %@",
             isPreFirstSession ? @"before first session" : @"after first session"];
            continue;
        }

        ADJClientActionRemoveStorageAction *_Nonnull clientActionRemoveStorageAction = [[ADJClientActionRemoveStorageAction alloc]
                                                                                        initWithClientActionStorage:clientActionStorage
                                                                                        elementPosition:elementPosition];

        [clientActionHandler ccHandleClientActionWithClientActionIoInjectedData:clientActionData.ioData
                                                                   apiTimestamp:clientActionData.apiTimestamp
                                                clientActionRemoveStorageAction:clientActionRemoveStorageAction];
    }
}

- (nullable id<ADJClientActionHandler>)clientActionHandlerWithId:(nonnull ADJNonEmptyString *)clientActionHandlerId
                                       postSdkInitRootController:(nonnull ADJPostSdkInitRootController *)postSdkInitRootController {

    if ([ADJAdRevenueControllerClientActionHandlerId isEqualToString:clientActionHandlerId.stringValue]) {
        return postSdkInitRootController.adRevenueController;
    }
    /*
     if ([ADJBillingSubscriptionControllerClientActionHandlerId
     isEqualToString:clientActionHandlerId.stringValue])
     {
     return postSdkInitRootController.billingSubscriptionController;
     }
     if ([ADJLaunchedDeeplinkClientActionHandlerId
     isEqualToString:clientActionHandlerId.stringValue])
     {
     return postSdkInitRootController.launchedDeeplinkController;
     }
     */
    if ([ADJEventControllerClientActionHandlerId isEqualToString:clientActionHandlerId.stringValue]) {
        return postSdkInitRootController.eventController;
    }

    if ([ADJGlobalCallbackParametersControllerClientActionHandlerId isEqualToString:clientActionHandlerId.stringValue]) {
        return postSdkInitRootController.globalCallbackParametersController;
    }

    if ([ADJGlobalPartnerParametersControllerClientActionHandlerId isEqualToString:clientActionHandlerId.stringValue]) {
        return postSdkInitRootController.globalPartnerParametersController;
    }

    if ([ADJPushTokenControllerClientActionHandlerId isEqualToString:clientActionHandlerId.stringValue]) {
        return postSdkInitRootController.pushTokenController;
    }
    /*
     if ([ADJThirdPartySharingControllerClientActionHandlerId
     isEqualToString:clientActionHandlerId.stringValue])
     {
     return postSdkInitRootController.thirdPartySharingController;
     }
     */

    return nil;
}

@end

