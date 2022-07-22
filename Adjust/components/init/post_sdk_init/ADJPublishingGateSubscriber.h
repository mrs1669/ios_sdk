//
//  ADJPublishingGateSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJPublisherBase.h"

@protocol ADJPublishingGateSubscriber <NSObject>

- (void)ccAllowedToPublishNotifications;

@end

@interface ADJPublishingGatePublisher : ADJPublisherBase<id<ADJPublishingGateSubscriber>>
@end
