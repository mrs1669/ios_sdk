//
//  ADJAttributionState.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJAttributionResponseData.h"
#import "ADJAttributionStateData.h"
#import "ADJValueWO.h"
#import "ADJSessionResponseData.h"
#import "ADJSdkResponseData.h"
#import "ADJDelayData.h"

@interface ADJAttributionState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
              doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
                        isFirstSessionInQueue:(BOOL)isFirstSessionInQueue;

// public api
- (BOOL)stopAskingWhenReceivedAcceptedAttributionResponseWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                                                 attributionResponseData:(nonnull ADJAttributionResponseData *)attributionResponseData
                                                           changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
                                                                attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO;

- (nullable NSString *)startAskingWhenReceivedProcessedSessionResponseWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                                                                  sessionResponseData:(nonnull ADJSessionResponseData *)sessionResponseData
                                                                        changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
                                                                             attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO;

- (nullable NSString *)startAskingWhenReceivedAcceptedSdkResponseWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                                                                     sdkResponse:(nonnull id<ADJSdkResponseData>)sdkResponse
                                                                   changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
                                                                                     delayDataWO:(nonnull ADJValueWO<ADJDelayData *> *)delayDataWO;

- (nonnull NSString *)statusEventAtGateOpenWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData;

- (nullable NSString *)startAskingWhenSdkStartWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                                                 isFirstStart:(BOOL)isFirstStart
                                                changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO;

@end
