//
//  ADJKeepAlivePingSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 01.02.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJKeepAlivePingSubscriber <NSObject>

- (void)didPingKeepAliveInActiveSession;

@end

@interface ADJKeepAlivePingPublisher :
    ADJPublisherBase<id<ADJKeepAlivePingSubscriber>>
@end

