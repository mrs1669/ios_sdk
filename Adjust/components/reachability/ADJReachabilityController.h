//
//  ADJReachabilityController.h
//  Adjust
//
//  Created by Pedro S. on 07.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJTeardownFinalizer.h"
#import "ADJSdkStartSubscriber.h"
#import "ADJReachabilitySubscriber.h"
#import "ADJThreadController.h"
#import "ADJPublisherController.h"

//- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus;

@interface ADJReachabilityController : ADJCommonBase<
   ADJTeardownFinalizer,
   // subscriptions
    ADJSdkStartSubscriber
>

// publishers
@property (nonnull, readonly, strong, nonatomic)ADJReachabilityPublisher *reachabilityPublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             threadController:(nonnull ADJThreadController *)threadController
                               targetEndpoint:(nonnull NSString *)targetEndpoint
                          publisherController:(nonnull ADJPublisherController *)publisherController;

@end
