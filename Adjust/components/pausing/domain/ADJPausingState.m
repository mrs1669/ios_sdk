//
//  ADJPausingState.m
//  Adjust
//
//  Created by Pedro S. on 09.03.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPausingState.h"

#import "ADJConstants.h"

@interface ADJPausingState ()
#pragma mark - Injected dependencies
@property (readwrite, assign, nonatomic) BOOL canSendInBackground;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasSdkStart;
@property (readwrite, assign, nonatomic) BOOL canPublish;
@property (readwrite, assign, nonatomic) BOOL isPaused;
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL isOffline;
@property (readwrite, assign, nonatomic) BOOL isNetworkReachable;
@property (readwrite, assign, nonatomic) BOOL isSdkActive;

@end

@implementation ADJPausingState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                          canSendInBackground:(BOOL)canSendInBackground {
    self = [super initWithLoggerFactory:loggerFactory source:@"PausingState"];
    _canSendInBackground = canSendInBackground;

    _canPublish = NO;

    _hasSdkStart = NO;

    _isPaused = ADJIsSdkPausedWhenStarting;

    _isOnForeground = ADJIsSdkInForegroundWhenStarting;

    _isOffline = ADJIsSdkOfflineWhenStarting;

    _isNetworkReachable = ADJIsNetworkReachableWhenStarting;

    _isSdkActive = ADJIsSdkActiveWhenStarting;

    return self;
}

#pragma mark Public API
- (BOOL)ignoringForegroundOrBackground {
    return self.canSendInBackground;
}

- (BOOL)publishPauseOrElseResumeWhenCanPublish {
    self.canPublish = YES;

    return self.isPaused;
}

- (BOOL)publishResumeWhenNetworkIsReachableWithSource:(nonnull NSString *)source {
    self.isNetworkReachable = YES;

    return [self publishResumeSendingWithSource:source];
}

- (BOOL)publishPauseWhenNetworkIsUnreachableWithSource:(nonnull NSString *)source {
    self.isNetworkReachable = NO;

    return [self publishPauseSendingWithSource:source];
}

- (BOOL)publishResumeWhenForegroundWithSource:(nonnull NSString *)source {
    self.isOnForeground = YES;

    return [self publishResumeSendingWithSource:source];
}

- (BOOL)publishPauseWhenBackgroundWithSource:(nonnull NSString *)source {
    self.isOnForeground = NO;

    return [self publishPauseSendingWithSource:source];
}

- (BOOL)publishResumeWhenOnlineWithSource:(nonnull NSString *)source {
    self.isOffline = NO;

    return [self publishResumeSendingWithSource:source];
}

- (BOOL)publishPauseWhenOfflineWithSource:(nonnull NSString *)source {
    self.isOffline = YES;

    return [self publishPauseSendingWithSource:source];
}

- (BOOL)publishResumeWhenSdkActiveWithSource:(nonnull NSString *)source {
    self.isSdkActive = YES;

    return [self publishResumeSendingWithSource:source];
}

- (BOOL)publishPauseWhenSdkNotActiveWithSource:(nonnull NSString *)source {
    self.isSdkActive = NO;

    return [self publishPauseSendingWithSource:source];
}

- (BOOL)publishResumeWhenSdkStartWithSource:(nonnull NSString *)source {
    self.hasSdkStart = YES;

    return [self publishResumeSendingWithSource:source];
}

#pragma mark Internal Methods
- (BOOL)publishResumeSendingWithSource:(nonnull NSString *)source {
    if (! self.isPaused) {
        [self logCannotResumeWithSource:source reason:@"already not paused"];
        return NO;
    }

    if (self.isOffline) {
        [self logCannotResumeWithSource:source reason:@"offline"];
        return NO;
    }

    if (! self.hasSdkStart) {
        [self logCannotResumeWithSource:source reason:@"not started"];
        return NO;
    }

    if (! self.canSendInBackground && ! self.isOnForeground) {
        [self logCannotResumeWithSource:source reason:@"on the background"];
        return NO;
    }

    if (! self.isNetworkReachable) {
        [self logCannotResumeWithSource:source reason:@"network is not reachable"];
        return NO;
    }

    if (! self.isSdkActive) {
        [self logCannotResumeWithSource:source reason:@"is not active"];
        return NO;
    }

    self.isPaused = NO;

    if (! self.canPublish) {
        [self.logger debug:@"Cannot publish resume sending from %@ yet", source];
        return NO;
    }

    return YES;
}

- (void)logCannotResumeWithSource:(nonnull NSString *)source reason:(nonnull NSString *)reason {
    [self.logger debug:@"Cannot resume sending from %@, since the SDK is %@", source, reason];
}

- (BOOL)publishPauseSendingWithSource:(nonnull NSString *)source {

    if (self.isPaused) {
        [self.logger debug:@"Cannot pause sending from %@,"
         " since the SDK is already paused", source];

        return NO;
    }

    self.isPaused = YES;

    if (! self.canPublish) {
        [self.logger debug:@"Cannot publish pause sending from %@ yet", source];
        return NO;
    }

    return YES;
}

@end

