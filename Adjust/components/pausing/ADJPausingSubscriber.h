//
//  ADJPausingSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJFromCanPublish;
FOUNDATION_EXPORT NSString *const ADJResumeFromSdkStart;
FOUNDATION_EXPORT NSString *const ADJResumeFromSdkActive;
FOUNDATION_EXPORT NSString *const ADJPauseFromSdkNotActive;
FOUNDATION_EXPORT NSString *const ADJResumeFromForeground;
FOUNDATION_EXPORT NSString *const ADJPauseFromBackground;
FOUNDATION_EXPORT NSString *const ADJResumeFromSdkOnline;
FOUNDATION_EXPORT NSString *const ADJPauseFromSdkOffline;
FOUNDATION_EXPORT NSString *const ADJResumeFromNetworkReachable;
FOUNDATION_EXPORT NSString *const ADJPauseFromNetworkUnreachable;

NS_ASSUME_NONNULL_END

@protocol ADJPausingSubscriber <NSObject>

- (void)didResumeSendingWithSource:(nonnull NSString *)source;
- (void)didPauseSendingWithSource:(nonnull NSString *)source;

@end

@interface ADJPausingPublisher : ADJPublisherBase<id<ADJPausingSubscriber>>
@end
