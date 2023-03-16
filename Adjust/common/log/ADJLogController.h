//
//  ADJLogController.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogCollector.h"
#import "ADJLoggerFactory.h"
#import "ADJSdkInitSubscriber.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJLogSubscriber.h"
#import "ADJLogger.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJSdkConfigData.h"
#import "ADJPublisherController.h"
#import "ADJInstanceIdData.h"

@interface ADJLogController : NSObject<
    ADJLogCollector,
    ADJLoggerFactory,
    // subscriptions
    ADJSdkInitSubscriber,
    ADJPublishingGateSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJLogPublisher *logPublisher;

// instantiation
- (nonnull instancetype)initWithSdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
                          publisherController:(nonnull ADJPublisherController *)publisherController
                                   instanceId:(nonnull ADJInstanceIdData *)instanceId
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (void)injectDependeciesWithCommonExecutor:(nonnull ADJSingleThreadExecutor *)commonExecutor;

@end
