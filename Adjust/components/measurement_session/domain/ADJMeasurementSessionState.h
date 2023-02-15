//
//  ADJMeasurementSessionState.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJTimeLengthMilli.h"
#import "ADJMeasurementSessionStateData.h"
#import "ADJValueWO.h"
#import "ADJMeasurementSessionData.h"
#import "ADJPackageSessionData.h"
#import "ADJTimestampMilli.h"

@interface ADJMeasurementSessionState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
           minMeasurementSessionIntervalMilli:(nonnull ADJTimeLengthMilli *)minMeasurementSessionIntervalMilli;

// public properties
@property (readonly, assign, nonatomic) BOOL hasFirstMeasurementSessionStartHappened;

// public api
- (BOOL)canMeasurementSessionBecomeActiveWhenSdkInit;

- (BOOL)canMeasurementSessionBecomeActiveWhenAppWentToTheForeground;

- (BOOL)canMeasurementSessionBecomeActiveWhenSdkBecameActive;

- (BOOL)changeToActiveSessionWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                          sdkStartStateEventWO:(nonnull ADJValueWO<NSString *> *)sdkStartStateEventWO
                               changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                          packageSessionDataWO:(nonnull ADJValueWO<ADJPackageSessionData *> *)packageSessionDataWO
                                 nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli
                                                        source:(nonnull NSString *)source;

- (void)appWentToTheBackgroundWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                                changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                                  nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli;

- (void)sdkBecameNotActiveWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                            changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                              nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli;

- (void)keepAlivePingedWithCurrentMeasurementSessionData:(nonnull ADJMeasurementSessionStateData *)currentMeasurementSessionStateData
                         changedMeasurementSessionDataWO:(nonnull ADJValueWO<ADJMeasurementSessionData *> *)changedMeasurementSessionDataWO
                           nonMonotonicNowTimestampMilli:(nonnull ADJTimestampMilli *)nonMonotonicNowTimestampMilli;

@end
