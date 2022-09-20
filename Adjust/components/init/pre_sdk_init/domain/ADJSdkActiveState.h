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
                              isGdprForgotten:(BOOL)isGdprForgotten;

// public api
- (BOOL)sdkInitWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                             adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger;

- (void)inactivateSdkWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                            sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
                       changedSdkActiveStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)changedSdkActiveStateDataWO
                                   adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger;

- (void)reactivateSdkWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                            sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
                       changedSdkActiveStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)changedSdkActiveStateDataWO
                                   adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger;

- (nonnull NSString *)canPerformActiveActionWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                                                                   source:(nonnull NSString *)source;

- (void)canNowPublishWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                            sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO;

- (void)gdprForgetEventReceivedWithSdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO;

- (BOOL)tryForgetDeviceWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                              sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
                                     adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger;

@end
