//
//  ADJSdkPackageCreatingSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJStringMap.h"
#import "ADJStringMapBuilder.h"

@protocol ADJSdkPackageCreatingSubscriber <NSObject>

- (void)willCreatePackageWithClientSdk:(nonnull NSString *)clientSdk
                                  path:(nonnull NSString *)path
                            parameters:(nonnull ADJStringMap *)parameters
                     parametersToWrite:(nonnull ADJStringMapBuilder *)parametersToWrite;

@end

@interface ADJSdkPackageCreatingPublisher : ADJPublisherBase<id<ADJSdkPackageCreatingSubscriber>>
@end
