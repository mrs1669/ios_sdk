//
//  ADJPausingState.h
//  Adjust
//
//  Created by Pedro S. on 09.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"

@interface ADJPausingState : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    canSendInBackground:(BOOL)canSendInBackground;

// public api
- (BOOL)ignoringForegroundOrBackground;

- (BOOL)publishPauseOrElseResumeWhenCanPublish;

- (BOOL)publishResumeWhenNetworkIsReachableWithSource:(nonnull NSString *)source;
- (BOOL)publishPauseWhenNetworkIsUnreachableWithSource:(nonnull NSString *)source;

- (BOOL)publishResumeWhenForegroundWithSource:(nonnull NSString *)source;
- (BOOL)publishPauseWhenBackgroundWithSource:(nonnull NSString *)source;

- (BOOL)publishResumeWhenOnlineWithSource:(nonnull NSString *)source;
- (BOOL)publishPauseWhenOfflineWithSource:(nonnull NSString *)source;

- (BOOL)publishResumeWhenSdkActiveWithSource:(nonnull NSString *)source;
- (BOOL)publishPauseWhenSdkNotActiveWithSource:(nonnull NSString *)source;

- (BOOL)publishResumeWhenSdkStartWithSource:(nonnull NSString *)source;

@end
