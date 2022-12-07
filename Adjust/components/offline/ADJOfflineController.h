//
//  ADJOfflineController.h
//  Adjust
//
//  Created by Pedro S. on 17.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJOfflineSubscriber.h"
#import "ADJPublishersRegistry.h"

@interface ADJOfflineController : ADJCommonBase<
    // subscriptions
    ADJPublishingGateSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJOfflinePublisher *offlinePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;

// public api
- (void)ccPutSdkOffline;
- (void)ccPutSdkOnline;

@end

