//
//  ADJPostSdkStartRoot.m
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJPostSdkStartRoot.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJAdRevenueController *adRevenueController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJBillingSubscriptionController *billingSubscriptionController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJLaunchedDeeplinkController *launchedDeeplinkController;
 @property (nonnull, readonly, strong, nonatomic) ADJEventController *eventController;
 @property (nonnull, readonly, strong, nonatomic) ADJPushTokenController *pushTokenController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJThirdPartySharingController *thirdPartySharingController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJGlobalCallbackParametersController *globalCallbackParametersController;
 @property (nonnull, readonly, strong, nonatomic)
     ADJGlobalPartnerParametersController *globalPartnerParametersController;
 */

@interface ADJPostSdkStartRoot ()
#pragma mark - Injected dependencies
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
    NSDictionary<NSString *, id<ADJClientActionHandler>> *clientHandlerMapById;

@end

@implementation ADJPostSdkStartRoot
#pragma mark Instantiation
- (nonnull instancetype)
    initWithClientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    storageRoot:(nonnull ADJStorageRoot *)storageRoot
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
{
    self = [super init];

    _adRevenueController = [[ADJAdRevenueController alloc]
                            initWithLoggerFactory:loggerFactory
                            sdkPackageBuilder:sdkPackageBuilder
                            mainQueueController:mainQueueController];

    _billingSubscriptionController = [[ADJBillingSubscriptionController alloc]
                                      initWithLoggerFactory:loggerFactory
                                      sdkPackageBuilder:sdkPackageBuilder
                                      mainQueueController:mainQueueController];

    _launchedDeeplinkController = [[ADJLaunchedDeeplinkController alloc]
                                   initWithLoggerFactory:loggerFactory
                                   sdkPackageBuilder:sdkPackageBuilder
                                   mainQueueController:mainQueueController];

    _eventController = [[ADJEventController alloc]
                        initWithLoggerFactory:loggerFactory
                        sdkPackageBuilder:sdkPackageBuilder
                        eventStateStorage:storageRoot.eventStateStorage
                        eventDeduplicationStorage:storageRoot.eventDeduplicationStorage
                        mainQueueController:mainQueueController
                        maxCapacityEventDeduplication:
                            clientConfigData.eventIdDeduplicationMaxCapacity];

    _pushTokenController = [[ADJPushTokenController alloc]
                            initWithLoggerFactory:loggerFactory
                            sdkPackageBuilder:sdkPackageBuilder
                            mainQueueController:mainQueueController];

    _thirdPartySharingController = [[ADJThirdPartySharingController alloc]
                                    initWithLoggerFactory:loggerFactory
                                    sdkPackageBuilder:sdkPackageBuilder
                                    mainQueueController:mainQueueController];

    _globalCallbackParametersController =
        [[ADJGlobalCallbackParametersController alloc]
         initWithLoggerFactory:loggerFactory
         storage:storageRoot.globalCallbackParametersStorage];

    _globalPartnerParametersController =
        [[ADJGlobalPartnerParametersController alloc]
         initWithLoggerFactory:loggerFactory
         storage:storageRoot.globalPartnerParametersStorage];

    _clientHandlerMapById =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         _adRevenueController, ADJAdRevenueControllerClientActionHandlerId,
         _billingSubscriptionController, ADJBillingSubscriptionControllerClientActionHandlerId,
         _eventController, ADJEventControllerClientActionHandlerId,
         _globalCallbackParametersController,
            ADJGlobalCallbackParametersControllerClientActionHandlerId,
         _globalPartnerParametersController,
            ADJGlobalPartnerParametersControllerClientActionHandlerId,
         _launchedDeeplinkController, ADJLaunchedDeeplinkClientActionHandlerId,
         _pushTokenController, ADJPushTokenControllerClientActionHandlerId,
         _thirdPartySharingController, ADJThirdPartySharingControllerClientActionHandlerId,
         nil];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nullable id<ADJClientActionHandler>)handlerById:(nonnull ADJNonEmptyString *)clientHandlerId {
    return [self.clientHandlerMapById objectForKey:clientHandlerId.stringValue];
}

#pragma mark - ADJClientActionsAPI
- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData {
    [self.adRevenueController ccTrackAdRevenueWithClientData:clientAdRevenueData];
}

- (void)ccTrackBillingSubscriptionWithClientData:
    (nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
{
    [self.billingSubscriptionController
     ccTrackBillingSubscriptionWithClientData:clientBillingSubscriptionData];
}

- (void)ccTrackLaunchedDeeplinkWithClientData:
    (nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData
{
    [self.launchedDeeplinkController
     ccTrackLaunchedDeeplinkWithClientData:clientLaunchedDeeplinkData];
}

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData {
    [self.eventController ccTrackEventWithClientData:clientEventData];
}

- (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData {
    [self.pushTokenController ccTrackPushTokenWithClientData:clientPushTokenData];
}

- (void)ccTrackThirdPartySharingWithClientData:
    (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
{
    [self.thirdPartySharingController
     ccTrackThirdPartySharingWithClientData:clientThirdPartySharingData];
}

- (void)ccAddGlobalCallbackParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController
     ccAddGlobalCallbackParameterWithClientData:clientAddGlobalCallbackParameterActionData];
}

- (void)ccRemoveGlobalCallbackParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData {
    [self.globalCallbackParametersController
     ccRemoveGlobalCallbackParameterWithClientData:
         clientRemoveGlobalCallbackParameterActionData];
}

- (void)ccClearGlobalCallbackParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData {
    [self.globalCallbackParametersController
     ccClearGlobalCallbackParameterWithClientData:
         clientClearGlobalCallbackParametersActionData];
}

- (void)ccAddGlobalPartnerParameterWithClientData:(nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData{
    [self.globalPartnerParametersController
     ccAddGlobalPartnerParameterWithClientData:clientAddGlobalPartnerParameterActionData];
}

- (void)ccRemoveGlobalPartnerParameterWithClientData:(nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData {
    [self.globalPartnerParametersController
     ccRemoveGlobalPartnerParameterWithClientData:clientRemoveGlobalPartnerParameterActionData];
}

- (void)ccClearGlobalPartnerParametersWithClientData:(nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData {
    [self.globalPartnerParametersController
     ccClearGlobalPartnerParameterWithClientData:clientClearGlobalPartnerParametersActionData];
}
@end
