//
//  ADJPluginForegroundPublisher.m
//  Adjust
//
//  Created by Pedro S. on 16.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPluginForegroundPublisher.h"

#pragma mark Private class
@interface ADJForegroundPublisherWrapper : ADJPublisherBase<id<ADJAdjustForegroundSubscriber>> @end
@implementation ADJForegroundPublisherWrapper @end

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic)
     ADJPublisherBase<id<ADJAdjustForegroundSubscriber>> *publisher;
 */

@implementation ADJPluginForegroundPublisher
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _publisher = [[ADJForegroundPublisherWrapper alloc] initWithoutSubscriberProtocol];

    return self;
}

#pragma mark Public API
#pragma mark - ADJAdjustForegroundPublisher
- (void)addForegroundSubscriber:(nonnull id<ADJAdjustForegroundSubscriber>)foregroundSubscriber {
    [self.publisher addSubscriber:foregroundSubscriber];
}

@end
