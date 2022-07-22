//
//  ADJKeepAliveSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJKeepAliveSubscriber <NSObject>

- (void)didKeepAlivePing;

@end

@interface ADJKeepAlivePublisher : ADJPublisherBase<id<ADJKeepAliveSubscriber>>
@end
