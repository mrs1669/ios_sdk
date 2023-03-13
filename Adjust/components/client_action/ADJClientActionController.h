//
//  ADJClientActionController.h
//  Adjust
//
//  Created by Genady Buchatsky on 29.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJClientActionsAPI.h"
#import "ADJClientActionsAPIPostSdkStart.h"
#import "ADJClientActionStorage.h"
#import "ADJClock.h"

@interface ADJClientActionController : ADJCommonBase<ADJClientActionsAPI>
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          clientActionStorage:(nonnull ADJClientActionStorage *)clientActionStorage
                                        clock:(nonnull ADJClock *)clock;

// public api
- (void)ccSetDependencyClientActionsPostSdkStart:(nonnull id<ADJClientActionsAPIPostSdkStart>)clientActionsPostSdkStart;

- (nonnull id<ADJClientActionsAPI>)ccClientMeasurementActions;

- (void)ccPreSdkStartWithPreFirstSession:(BOOL)isPreFirstSession;

- (void)ccPostSdkStart;
@end
