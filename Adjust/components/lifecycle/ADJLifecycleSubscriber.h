//
//  ADJLifecycleSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

@protocol ADJLifecycleSubscriber <NSObject>

- (void)onForegroundWithIsFromClientContext:(BOOL)isFromClientContext;
- (void)onBackgroundWithIsFromClientContext:(BOOL)isFromClientContext;

@end

@interface ADJLifecyclePublisher : ADJPublisherBase<id<ADJLifecycleSubscriber>>
@end
