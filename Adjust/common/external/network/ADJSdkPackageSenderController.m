//
//  ADJSdkPackageSenderController.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageSenderController.h"

#import "ADJSdkPackageSender.h"

#pragma mark Private class
@implementation ADJSdkPackageSendingPublisher @end
@implementation ADJSdkResponsePublisher @end

#pragma mark Fields
#pragma mark - Public properties
/*
 @property (nonnull, readonly, strong, nonatomic)
 ADJSdkPackageSendingPublisher *sdkPackageSendingPublisher;
 @property (nonnull, readonly, strong, nonatomic)
 ADJSdkResponsePublisher *sdkResponsePublisher;
 */

@interface ADJSdkPackageSenderController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *adjustUrlStrategy;
// TODO data residency
@property (nonnull, readonly, strong, nonatomic) ADJClientCustomEndpointData *clientCustomEndpointData;

#pragma mark - Internal variables
@end

@implementation ADJSdkPackageSenderController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          networkEndpointData:(nonnull ADJNetworkEndpointData *)networkEndpointData
                            adjustUrlStrategy:(nullable ADJNonEmptyString *)adjustUrlStrategy
                     clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData {
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"SdkPackageSenderController"];
    _networkEndpointData = networkEndpointData;
    _adjustUrlStrategy = adjustUrlStrategy;
    _clientCustomEndpointData = clientCustomEndpointData;

    _sdkPackageSendingPublisher = [[ADJSdkPackageSendingPublisher alloc] init];

    _sdkResponsePublisher = [[ADJSdkResponsePublisher alloc] init];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkPackageSenderFactory
- (nonnull ADJSdkPackageSender *)createSdkPackageSenderWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                                       sourceDescription:(nonnull NSString *)sourceDescription
                                                   threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory {
    return [[ADJSdkPackageSender alloc] initWithLoggerFactory:loggerFactory
                                            sourceDescription:sourceDescription
                                        threadExecutorFactory:threadExecutorFactory
                                   sdkPackageSendingCollector:self
                                         sdkResponseCollector:self
                                          networkEndpointData:self.networkEndpointData
                                            adjustUrlStrategy:self.adjustUrlStrategy
                                     clientCustomEndpointData:self.clientCustomEndpointData];
}

#pragma mark - ADJSdkPackageSendingSubscriber
- (void)willSendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                   parametersToAdd:(nonnull ADJStringMapBuilder *)parametersToAdd
                      headersToAdd:(nonnull ADJStringMapBuilder *)headersToAdd {
    [self.sdkPackageSendingPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkPackageSendingSubscriber> _Nonnull subscriber)
     {
        [subscriber willSendSdkPackageWithData:sdkPackageData
                               parametersToAdd:parametersToAdd
                                  headersToAdd:headersToAdd];
    }];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    [self.logger debugDev:@"Received response"
                      key:@"sdk response"
                    value:sdkResponseData.description];

    [self.sdkResponsePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkResponseSubscriber> _Nonnull subscriber)
     {
        [subscriber didReceiveSdkResponseWithData:sdkResponseData];
    }];
}

@end

