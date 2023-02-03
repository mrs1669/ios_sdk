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

#import "ADJSdkPackageSenderController.h"

@interface ADJPreSdkInitRoot : ADJCommonBase <ADJPreSdkInitRootBag>
// instantiation
- (nonnull instancetype)
    initWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag;

// public api
- (void)ccSdkInitWithClientConfg:(nonnull ADJClientConfigData *)clientConfig
                 instanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag;

- (void)
    ccSetDependenciesAtSdkInitWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder*)sdkPackageBuilder
    sdkPackageSenderController:(nonnull ADJSdkPackageSenderController *)sdkPackageSenderController;

- (void)ccSubscribeToPublishers:(nonnull ADJPublisherController *)publisherController;

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end
