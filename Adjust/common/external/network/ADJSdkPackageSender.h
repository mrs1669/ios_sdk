//
//  ADJSdkPackageSender.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkResponseData.h"
#import "ADJSdkPackageSendingSubscriber.h"
#import "ADJSdkResponseSubscriber.h"
#import "ADJThreadExecutorFactory.h"
#import "ADJNetworkEndpointData.h"
#import "ADJClientConfigData.h"
#import "ADJSdkPackageData.h"
#import "ADJStringMapBuilder.h"

@protocol ADJSdkResponseCallbackSubscriber <NSObject>

- (void)sdkResponseCallbackWithResponseData:(nonnull id<ADJSdkResponseData>)sdkResponseData;

@end

@interface ADJSdkPackageSender : ADJCommonBase<NSURLSessionDelegate>
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceDescription:(nonnull NSString *)sourceDescription
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSendingCollector:
        (nonnull id<ADJSdkPackageSendingSubscriber>)sdkPackageSendingCollector
    sdkResponseCollector:(nonnull id<ADJSdkResponseSubscriber>)sdkResponseCollector
    networkEndpointData:(nonnull ADJNetworkEndpointData *)networkEndpointData
    adjustUrlStrategy:(nullable ADJNonEmptyString *)adjustUrlStrategy
    clientCustomEndpointData:(nullable ADJClientCustomEndpointData *)clientCustomEndpointData;

// public api
- (void)sendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
             sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
              responseCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)responseCallback;

- (nonnull NSString *)defaultTargetUrl;

@end
