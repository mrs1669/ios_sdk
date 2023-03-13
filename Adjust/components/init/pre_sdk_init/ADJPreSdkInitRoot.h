//
//  ADJPreSdkInitRoot.h
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJInstanceRootBag.h"
#import "ADJPreSdkInitRootBag.h"
#import "ADJPostSdkInitRootBag.h"

@interface ADJPreSdkInitRoot : ADJCommonBase <ADJPreSdkInitRootBag>
// instantiation
- (nonnull instancetype)
    initWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag;

// public api
- (void)ccSetDependenciesAtSdkInitWithInstanceRootBag:(nonnull id<ADJInstanceRootBag>)instanceRootBag
                                   postSdkInitRootBag:(nonnull id<ADJPostSdkInitRootBag>)postSdkInitRootBag
                            clientActionsPostSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)clientActionsPostSdkStart;

- (void)ccSubscribeToPublishers:(nonnull ADJPublisherController *)publisherController;

- (void)finalizeAtTeardownWithBlock:(nullable void (^)(void))closeStorageBlock;

@end
