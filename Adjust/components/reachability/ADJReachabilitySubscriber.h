//
//  ADJReachabilitySubscriber.h
//  Adjust
//
//  Created by Pedro S. on 06.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJReachabilitySubscriber <NSObject>

- (void)didBecomeReachable;
- (void)didBecomeUnreachable;

@end

@interface ADJReachabilityPublisher : ADJPublisherBase<id<ADJReachabilitySubscriber>>
@end
