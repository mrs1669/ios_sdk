//
//  ADJSdkPackageSenderController.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkPackageSenderFactory.h"
#import "ADJSdkPackageSendingSubscriber.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJNetworkEndpointData.h"
#import "ADJClientConfigData.h"
#import "ADJPublishersRegistry.h"

@interface ADJSdkPackageSenderController : ADJCommonBase<
    ADJSdkPackageSenderFactory,
    ADJSdkPackageSendingSubscriber,
    ADJSdkResponseSubscriber
>
// publishers
@property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSendingPublisher *sdkPackageSendingPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSdkResponsePublisher *sdkResponsePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          networkEndpointData:(nonnull ADJNetworkEndpointData *)networkEndpointData
                            adjustUrlStrategy:(nullable ADJNonEmptyString *)adjustUrlStrategy
                     clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData
                           publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry;

@end
