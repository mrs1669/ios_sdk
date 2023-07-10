//
//  ADJAdidController.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJAdidStateStorage.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJThreadController.h"
#import "ADJPublisherController.h"

@interface ADJAdidController : ADJCommonBase<
    // subscriptions
    ADJSdkResponseSubscriber
>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    adidStateStorage:(nonnull ADJAdidStateStorage *)adidStateStorage
    threadController:(nonnull ADJThreadController *)threadController
    publisherController:(nonnull ADJPublisherController *)publisherController;


@end
