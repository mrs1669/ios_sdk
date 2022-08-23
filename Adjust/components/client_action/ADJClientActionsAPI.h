//
//  ADJClientActionsAPI.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientEventData.h"
#import "ADJClientAdRevenueData.h"

/*
 #import "ADJClientBillingSubscriptionData.h"
 #import "ADJClientLaunchedDeeplinkData.h"
 #import "ADJClientPushTokenData.h"
 #import "ADJClientAddGlobalParameterData.h"
 #import "ADJClientRemoveGlobalParameterData.h"
 #import "ADJClientClearGlobalParametersData.h"
 #import "ADJClientThirdPartySharingData.h"
 */
@protocol ADJClientActionsAPI <NSObject>

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData;

- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData;


/*

 - (void)ccTrackBillingSubscriptionWithClientData:
 (nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData;

 - (void)ccTrackLaunchedDeeplinkWithClientData:
 (nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData;

 - (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData;

 - (void)ccTrackThirdPartySharingWithClientData:
 (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData;

 - (void)ccAddGlobalCallbackParameterWithClientData:
 (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData;
 - (void)ccRemoveGlobalCallbackParameterWithClientData:
 (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData;
 - (void)ccClearGlobalCallbackParametersWithClientData:
 (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData;

 - (void)ccAddGlobalPartnerParameterWithClientData:
 (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData;
 - (void)ccRemoveGlobalPartnerParameterWithClientData:
 (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData;
 - (void)ccClearGlobalPartnerParametersWithClientData:
 (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData;
 */

@end

