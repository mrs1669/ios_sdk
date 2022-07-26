//
//  ADJSdkPackageSendingSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJSdkPackageData.h"
#import "ADJStringMapBuilder.h"

@protocol ADJSdkPackageSendingSubscriber <NSObject>

- (void)willSendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                   parametersToAdd:(nonnull ADJStringMapBuilder *)parametersToAdd
                      headersToAdd:(nonnull ADJStringMapBuilder *)headersToAdd;

@end

@interface ADJSdkPackageSendingPublisher : ADJPublisherBase<id<ADJSdkPackageSendingSubscriber>>
@end
