//
//  ADJPluginForegroundPublisher.h
//  Adjust
//
//  Created by Pedro S. on 16.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustForegroundSubscriber.h"
#import "ADJPublisherBase.h"

@interface ADJPluginForegroundPublisher : NSObject<ADJAdjustForegroundPublisher>
// instantiation
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// properties
@property (nonnull, readonly, strong, nonatomic) ADJPublisherBase<id<ADJAdjustForegroundSubscriber>> *publisher;

@end
