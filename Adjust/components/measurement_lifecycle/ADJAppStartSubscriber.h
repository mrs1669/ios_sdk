//
//  ADJAppStartSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 27.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJAppStartSubscriber <NSObject>

- (void)ccAppStart;

@end

@interface ADJAppStartPublisher : ADJPublisherBase<id<ADJAppStartSubscriber>>
@end
