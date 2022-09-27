//
//  ADJAdjustForegroundSubscriber.h
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustForegroundSubscriber <NSObject>

- (void)onForeground;

@end

@protocol ADJAdjustForegroundPublisher <NSObject>

- (void)addForegroundSubscriber:(nonnull id<ADJAdjustForegroundSubscriber>)foregroundSubscriber;

@end
