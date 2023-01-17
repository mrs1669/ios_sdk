//
//  ADJSdkActiveState.h
//  AdjustV5
//
//  Created by Pedro S. on 28.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJSdkActiveStateData.h"
#import "ADJLogger.h"
#import "ADJValueWO.h"

@interface ADJSdkActiveState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                           sdkActiveStateData:(nonnull ADJSdkActiveStateData *)sdkActiveStateData
                              isGdprForgotten:(BOOL)isGdprForgotten;
- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (BOOL)trySdkInit;
- (void)inactivateSdkWithActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)activeStatusEventWO
                           activeStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)activeStateDataWO;

- (void)reactivateSdkWithActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)activeStatusEventWO
                           activeStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)activeStateDataWO;

- (BOOL)canPerformActionWithSource:(nonnull NSString *)source errorMessage:(NSString * _Nullable * _Nullable)errorMessage;

- (nullable ADJValueWO<NSString *> *)gdprForgottenByEvent;

- (nullable ADJValueWO<NSString *> *)gdprForgottenByClient;

- (nonnull NSString *)sdkActiveStatus;
@end
