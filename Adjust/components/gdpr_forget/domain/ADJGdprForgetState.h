//
//  ADJGdprForgetState.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJGdprForgetStateData.h"
#import "ADJValueWO.h"

@interface ADJGdprForgetState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

// public api
- (BOOL)shouldStartTrackingWhenForgottenByClientWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                        changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                             gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO;

- (BOOL)shouldStartTrackingWhenSdkInitWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                   gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO;

- (void)canStartPublish;

- (BOOL)shouldStartTrackingWhenAppWentToTheForegroundWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData;

- (void)appWentToTheBackground;

- (BOOL)shouldStopTrackingWhenReceivedOptOutWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                    changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                         gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO;

- (BOOL)shouldStopTrackingWhenReceivedProcessedGdprResponseWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                                   changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                                        gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO;


@end

