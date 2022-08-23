//
//  ADJMainQueueController.h
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageSenderFactory.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPausingSubscriber.h"
#import "ADJOfflineSubscriber.h"
#import "ADJSdkPackageSendingSubscriber.h"
#import "ADJMainQueueStorage.h"
#import "ADJThreadController.h"
#import "ADJClock.h"
#import "ADJNetworkEndpointData.h"
#import "ADJBackoffStrategy.h"
#import "ADJClientConfigData.h"
#import "ADJAdRevenuePackageData.h"

/*
 #import "ADJBillingSubscriptionPackageData.h"
 #import "ADJClickPackageData.h"
 */
#import "ADJEventPackageData.h"
/*
 #import "ADJInfoResponseData.h"
 #import "ADJThirdPartySharingPackageData.h"
 */
#import "ADJSessionPackageData.h"

@interface ADJMainQueueController : ADJCommonBase<
ADJSdkResponseCallbackSubscriber,
// subscriptions
ADJSdkInitSubscriber,
ADJPausingSubscriber,
ADJOfflineSubscriber
>
- (void)
ccSubscribeToPublishersWithSdkInitPublisher:
(nonnull ADJSdkInitPublisher *)sdkInitPublisher
pausingPublisher:(nonnull ADJPausingPublisher *)pausingPublisher
offlinePublisher:(nonnull ADJOfflinePublisher *)offlinePublisher;

// instantiation
- (nonnull instancetype)
initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
mainQueueStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage
threadController:(nonnull ADJThreadController *)threadController
clock:(nonnull ADJClock *)clock
backoffStrategy:(nonnull ADJBackoffStrategy *)backoffStrategy
sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

// public api
- (BOOL)containsFirstSessionPackage;
//- (BOOL)containsAsaClickPackage;

- (void)addAdRevenuePackageToSendWithData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
                      sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

/*

 - (void)
 addBillingSubscriptionPackageToSendWithData:
 (nonnull ADJBillingSubscriptionPackageData *)billingSubscriptionPackageData
 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

 - (void)
 addClickPackageToSendWithData:(nonnull ADJClickPackageData *)clickPackageData
 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
 */

- (void)addEventPackageToSendWithData:(nonnull ADJEventPackageData *)eventPackageData
                  sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;

/*
 - (void)
 addInfoPackageToSendWithData:(nonnull ADJInfoPackageData *)infoPackageData
 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
 */
- (void)addSessionPackageToSendWithData:(nonnull ADJSessionPackageData *)sessionPackageData
                    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
/*
 - (void)
 addThirdPartySharingPackageToSendWithData:
 (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
 sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction;
 */
- (nonnull NSString *)defaultTargetUrl;

@end

