//
//  ADJPreSdkInitRootBag.h
//  Adjust
//
//  Created by Pedro Silva on 02.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkActiveController.h"
#import "ADJStorageRoot.h"
#import "ADJDeviceController.h"
#import "ADJClientActionController.h"
#import "ADJGdprForgetController.h"
#import "ADJLifecycleController.h"
#import "ADJOfflineController.h"
#import "ADJClientCallbacksController.h"
#import "ADJPluginController.h"
#import "ADJClientReturnExecutor.h"

@protocol ADJPreSdkInitRootBag <NSObject>

@property (nonnull, readonly, strong, nonatomic) ADJClientCallbacksController *clientCallbacksController;
@property (nonnull, readonly, strong, nonatomic) id<ADJClientReturnExecutor> clientReturnExecutor;
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetController *gdprForgetController;
@property (nonnull, readonly, strong, nonatomic) ADJLifecycleController *lifecycleController;
@property (nonnull, readonly, strong, nonatomic) ADJOfflineController *offlineController;
@property (nonnull, readonly, strong, nonatomic) ADJPluginController *pluginController;
@property (nonnull, readonly, strong, nonatomic) ADJStorageRoot *storageRoot;
@property (nonnull, readonly, strong, nonatomic) ADJClientActionController *clientActionController;
@property (nonnull, readonly, strong, nonatomic) ADJDeviceController *deviceController;
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveController *sdkActiveController;

@end
