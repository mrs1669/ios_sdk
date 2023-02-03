//
//  ADJMeasurementLifecycleState.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"

@interface ADJMeasurementLifecycleStateOutputData : NSObject

@property (readonly, assign, nonatomic) BOOL sdkStarted;
@property (readonly, assign, nonatomic) BOOL measurementResumed;
@property (readonly, assign, nonatomic) BOOL measurementPaused;

- (nullable instancetype)init NS_UNAVAILABLE;

@end

@interface ADJMeasurementLifecycleState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory;

// public api
- (nullable ADJMeasurementLifecycleStateOutputData *)postSdkInit;

- (nullable ADJMeasurementLifecycleStateOutputData *)foreground;
- (nullable ADJMeasurementLifecycleStateOutputData *)background;

- (nullable ADJMeasurementLifecycleStateOutputData *)sdkActive;
- (nullable ADJMeasurementLifecycleStateOutputData *)sdkNotActive;

@end
