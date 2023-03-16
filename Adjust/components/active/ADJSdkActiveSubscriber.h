//
//  ADJSdkActiveSubscriber.h
//  Adjust
//
//  Created by Pedro S. on 01.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJSdkActiveState.h"

@protocol ADJSdkActiveSubscriber <NSObject>

- (void)ccSdkActiveWithStatus:(nonnull ADJSdkActiveStatus)status;

@end

@interface ADJSdkActivePublisher : ADJPublisherBase<id<ADJSdkActiveSubscriber>>

@end
