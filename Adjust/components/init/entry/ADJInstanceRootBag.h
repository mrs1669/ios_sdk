//
//  ADJInstanceRootBag.h
//  Adjust
//
//  Created by Pedro Silva on 02.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogController.h"
#import "ADJThreadController.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJClock.h"
#import "ADJPublisherController.h"

@protocol ADJInstanceRootBag <NSObject>

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJSdkConfigData *sdkConfigData;
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;
@property (nullable, readonly, strong, nonatomic) NSString *sdkPrefix;

@property (nonnull, readonly, strong, nonatomic) ADJLogController *logController;
@property (nonnull, readonly, strong, nonatomic) ADJThreadController *threadController;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *commonExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJClock *clock;
@property (nonnull, readonly, strong, nonatomic) ADJPublisherController *publisherController;

@end
