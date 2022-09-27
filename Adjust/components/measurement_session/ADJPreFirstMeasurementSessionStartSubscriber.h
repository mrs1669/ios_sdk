//
//  ADJPreFirstMeasurementSessionStartSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJPreFirstMeasurementSessionStartSubscriber <NSObject>

- (void)ccPreFirstMeasurementSessionStart:(BOOL)hasFirstSessionHappened;

@end

@interface ADJPreFirstMeasurementSessionStartPublisher : ADJPublisherBase<id<ADJPreFirstMeasurementSessionStartSubscriber>>

@end
