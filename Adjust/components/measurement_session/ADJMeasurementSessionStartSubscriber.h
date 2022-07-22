//
//  ADJMeasurementSessionStartSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJMeasurementSessionStartStatusFirstSession;
FOUNDATION_EXPORT NSString *const ADJMeasurementSessionStartStatusFollowingSession;
FOUNDATION_EXPORT NSString *const ADJMeasurementSessionStartStatusNotNewSession;

NS_ASSUME_NONNULL_END

@protocol ADJMeasurementSessionStartSubscriber <NSObject>

- (void)ccMeasurementSessionStartWithStatus:(nonnull NSString *)measurementSessionStartStatus;

@end

@interface ADJMeasurementSessionStartPublisher : ADJPublisherBase<id<ADJMeasurementSessionStartSubscriber>>
@end
