//
//  ADJLifecycleController.h
//  Adjust
//
//  Created by Pedro Silva on 25.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJTeardownFinalizer.h"
#import "ADJPublishingGateSubscriber.h"
#import "ADJThreadController.h"
#import "ADJPublishersRegistry.h"

@interface ADJLifecycleController : ADJCommonBase<
    ADJTeardownFinalizer,
    ADJPublishingGateSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic) ADJLifecyclePublisher *lifecyclePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
              doNotReadCurrentLifecycleStatus:(BOOL)doNotReadCurrentLifecycleStatus
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;

// public api
- (void)ccForeground;
- (void)ccBackground;

@end
