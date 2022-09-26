//
//  ADJPluginPackageSendingPublisher.m
//  Adjust
//
//  Created by Pedro S. on 16.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPluginPackageSendingPublisher.h"

#pragma mark Private class
@interface ADJPackageSendingPublisherWrapper : ADJPublisherBase<id<ADJAdjustPackageSendingSubscriber>> @end

@implementation ADJPackageSendingPublisherWrapper @end

#pragma mark Fields
/* .h
 @property (nonnull, readonly, strong, nonatomic)
     ADJPublisherBase<id<ADJAdjustPackageSendingSubscriber>> *publisher;
 */

@implementation ADJPluginPackageSendingPublisher
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];

    _publisher = [[ADJPackageSendingPublisherWrapper alloc] init];

    return self;
}
#pragma mark Public API
#pragma mark - ADJAdjustPackageSendingPublisher
- (void)addPackageSendingSubscriber:(nonnull id<ADJAdjustPackageSendingSubscriber>)packageSendingSubscriber {
    [self.publisher addSubscriber:packageSendingSubscriber];
}

@end
