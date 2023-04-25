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
 @property (nonnull, readonly, strong, nonatomic) ADJSdkPackageSendingPublisher *sdkPackageSendingPublisher;
 @property (nonnull, readonly, strong, nonatomic) ADJSdkResponsePublisher *sdkResponsePublisher;
 */

@interface ADJSdkPackageSenderController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJNetworkEndpointData *networkEndpointData;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *urlStrategyBaseDomain;
@property (nullable, readonly, strong, nonatomic) AdjustDataResidency dataResidency;
@property (nullable, readonly, strong, nonatomic) ADJClientCustomEndpointData *clientCustomEndpointData;

#pragma mark - Internal variables
@end

@implementation ADJSdkPackageSenderController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    networkEndpointData:(nonnull ADJNetworkEndpointData *)networkEndpointData
    urlStrategyBaseDomain:(nullable ADJNonEmptyString *)urlStrategyBaseDomain
    dataResidency:(nullable AdjustDataResidency)dataResidency
    clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"SdkPackageSenderController"];
    _networkEndpointData = networkEndpointData;
    _urlStrategyBaseDomain = urlStrategyBaseDomain;
    _dataResidency = dataResidency;
    _clientCustomEndpointData = clientCustomEndpointData;

    _sdkPackageSendingPublisher = [[ADJSdkPackageSendingPublisher alloc]
                                   initWithSubscriberProtocol:@protocol(ADJSdkPackageSendingSubscriber)
                                   controller:publisherController];

    _sdkResponsePublisher = [[ADJSdkResponsePublisher alloc]
                             initWithSubscriberProtocol:@protocol(ADJSdkResponseSubscriber)
                             controller:publisherController];
    
    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkPackageSenderFactory
- (nonnull ADJSdkPackageSender *)
    createSdkPackageSenderWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceLoggerName:(nonnull NSString *)sourceLoggerName
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
{
    return [[ADJSdkPackageSender alloc] initWithLoggerFactory:loggerFactory
                                             sourceLoggerName:sourceLoggerName
                                        threadExecutorFactory:threadExecutorFactory
                                   sdkPackageSendingCollector:self
                                         sdkResponseCollector:self
                                          networkEndpointData:self.networkEndpointData
                                        urlStrategyBaseDomain:self.urlStrategyBaseDomain
                                                dataResidency:self.dataResidency
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
              stringValue:sdkResponseData.description];

    [self.sdkResponsePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkResponseSubscriber> _Nonnull subscriber)
     {
        [subscriber didReceiveSdkResponseWithData:sdkResponseData];
    }];
}

@end

