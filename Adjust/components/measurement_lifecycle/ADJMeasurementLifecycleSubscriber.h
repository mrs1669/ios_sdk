//
//  ADJMeasurementLifecycleSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJMeasurementLifecycleSubscriber <NSObject>

- (void)ccDidResumeMeasurementWithIsFirst:(BOOL)isFirstMeasurement;
- (void)ccDidPauseMeasurement;

@end

@interface ADJMeasurementLifecyclePublisher :
    ADJPublisherBase<id<ADJMeasurementLifecycleSubscriber>>
@end

