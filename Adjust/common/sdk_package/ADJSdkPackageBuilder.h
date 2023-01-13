//
//  ADJSdkPackageBuilder.h
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClock.h"
#import "ADJClientConfigData.h"

#import "ADJDeviceController.h"
#import "ADJGlobalCallbackParametersStorage.h"
#import "ADJGlobalPartnerParametersStorage.h"
#import "ADJEventStateStorage.h"
#import "ADJMeasurementSessionStateStorage.h"
#import "ADJSdkPackageCreatingSubscriber.h"
#import "ADJEventPackageData.h"
#import "ADJClientEventData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJClientAdRevenueData.h"
#import "ADJAttributionPackageData.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJClientBillingSubscriptionData.h"
#import "ADJClickPackageData.h"
#import "ADJClientLaunchedDeeplinkData.h"
#import "ADJInfoPackageData.h"
#import "ADJClientPushTokenData.h"
#import "ADJLogPackageData.h"
#import "ADJSessionPackageData.h"
#import "ADJClientThirdPartySharingData.h"
#import "ADJThirdPartySharingPackageData.h"
#import "ADJGdprForgetPackageData.h"
#import "ADJPackageSessionData.h"
#import "ADJPublisherController.h"

@interface ADJSdkPackageBuilder : ADJCommonBase
// publishers
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageCreatingPublisher *sdkPackageCreatingPublisher;

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    clock:(nonnull ADJClock *)clock
    clientSdk:(nonnull NSString *)clientSdk
    clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    deviceController:(nonnull ADJDeviceController *)deviceController
    globalCallbackParametersStorage:
        (nonnull ADJGlobalCallbackParametersStorage *)globalCallbackParametersStorage
    globalPartnerParametersStorage:
        (nonnull ADJGlobalPartnerParametersStorage *)globalPartnerParametersStorage
    eventStateStorage:(nonnull ADJEventStateStorage *)eventStateStorage
    measurementSessionStateStorage:
        (nonnull ADJMeasurementSessionStateStorage *)measurementSessionStateStorage
    publisherController:(nonnull ADJPublisherController *)publisherController;

- (nonnull ADJEventPackageData *)buildEventPackageWithClientData:(nonnull ADJClientEventData *)clientEventData
                                                    apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJAdRevenuePackageData *)buildAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData
                                                     apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJAttributionPackageData *)buildAttributionPackageWithInitiatedBy:(nullable NSString *)initatedBy;

- (nonnull ADJBillingSubscriptionPackageData *)buildBillingSubscriptionWithClientData:(nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData
                                                                         apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJClickPackageData *)buildLaunchedDeeplinkClickWithClientData:(nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData
                                                             apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJClickPackageData *)buildAsaAttributionClickWithToken:(nonnull ADJNonEmptyString *)asaAttibutionToken
                                       asaAttributionReadTimestamp:(nullable ADJTimestampMilli *)asaAttributionReadTimestamp;

- (nonnull ADJInfoPackageData *)buildInfoPackageWithClientData:(nonnull ADJClientPushTokenData*)clientPushTokenData
                                                  apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJLogPackageData *)buildLogPackageWithMessage:(nonnull ADJNonEmptyString *)logMessage
                                                 logLevel:(nonnull ADJAdjustLogLevel)logLevel
                                                logSource:(nonnull NSString *)logSource;

- (nonnull ADJSessionPackageData *)buildSessionPackageWithDataToOverwrite:(nonnull ADJPackageSessionData *)packageSessionDataToOverwrite;

- (nonnull ADJThirdPartySharingPackageData *)buildThirdPartySharingWithClientData:(nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData
                                                                     apiTimestamp:(nullable ADJTimestampMilli *)apiTimestamp;

- (nonnull ADJGdprForgetPackageData *)buildGdprForgetPackage;

+ (void)injectSentAtWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                          sentAtTimestamp:(nullable ADJTimestampMilli *)sentAtTimestamp;

+ (void)injectAttemptsWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                   attempts:(nullable ADJNonNegativeInt *)attempts;

+ (void)injectRemainingQueuSizeWithParametersBuilder:(nonnull ADJStringMapBuilder *)parametersBuilder
                                  remainingQueueSize:(nullable ADJNonNegativeInt *)remainingQueueSize;

@end
