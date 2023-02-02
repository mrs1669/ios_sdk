//
//  ADJPreSdkInitRoot.h
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJPreSdkInitRootBag.h"
#import "ADJInstanceRootBag.h"

@interface ADJPreSdkInitRoot : ADJCommonBase <ADJPreSdkInitRootBag>
// instantiation
- (nonnull instancetype)
    initWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag;

// public api
- (void)
    setDependenciesWithPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(nonnull ADJClock *)clock
    loggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(nonnull id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory;

- (void)subscribeToPublishers:(nonnull ADJPublisherController *)publisherController;

@end
