//
//  ADJSdkActiveSubscriber.h
//  Adjust
//
//  Created by Pedro S. on 01.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusActive;
FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusInactive;
FOUNDATION_EXPORT NSString *const ADJSdkActiveStatusForgotten;

NS_ASSUME_NONNULL_END

@protocol ADJSdkActiveSubscriber <NSObject>

- (void)ccSdkActiveWithStatus:(nonnull NSString *)status;

@end

@interface ADJSdkActivePublisher : ADJPublisherBase<id<ADJSdkActiveSubscriber>>

@end
