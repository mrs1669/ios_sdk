//
//  ADJOfflineController.m
//  Adjust
//
//  Created by Pedro S. on 17.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJOfflineController.h"

#import "ADJConstants.h"

#pragma mark Private class
@implementation ADJOfflinePublisher @end

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJOfflinePublisher *offlinePublisher;
 */

@interface ADJOfflineController ()
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isOffline;
@property (readwrite, assign, nonatomic) BOOL canPublish;

@end

@implementation ADJOfflineController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"ADJOfflineController"];

    _offlinePublisher = [[ADJOfflinePublisher alloc] init];

    _isOffline = ADJIsSdkOfflineWhenStarting;

    _canPublish = NO;

    return self;
}

#pragma mark Public API
- (void)ccPutSdkOffline {
    if (self.isOffline) {
        [self.logger infoClient:@"Cannot put sdk offline, since it's already offline"];
        return;
    }

    self.isOffline = YES;
    [self.logger infoClient:@"Sdk was put offline"];

    [self publishDidSdkBecomeOffline];
}

- (void)ccPutSdkOnline {
    if (! self.isOffline) {
        [self.logger infoClient:@"Cannot put sdk online, since it's already online"];
        return;
    }

    self.isOffline = NO;
    [self.logger infoClient:@"Sdk was put back online"];

    [self publishDidSdkBecomeOnline];
}

#pragma mark - NSNotificationCenter subscriptions
- (void)ccSubscribeToPublishersWithPublishingGatePublisher:(nonnull ADJPublishingGatePublisher *)publishingGatePublisher {
    [publishingGatePublisher addSubscriber:self];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    self.canPublish = YES;

    if (self.isOffline) {
        [self publishDidSdkBecomeOffline];
    } else {
        [self publishDidSdkBecomeOnline];
    }
}

#pragma mark Internal Methods
- (void)publishDidSdkBecomeOffline {
    if (! self.canPublish) {
        return;
    }

    [self.offlinePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJOfflineSubscriber> _Nonnull subscriber)
     {
        [subscriber didSdkBecomeOffline];
    }];
}

- (void)publishDidSdkBecomeOnline {
    if (! self.canPublish) {
        return;
    }

    [self.offlinePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJOfflineSubscriber> _Nonnull subscriber)
     {
        [subscriber didSdkBecomeOnline];
    }];
}

@end

