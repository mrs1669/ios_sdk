//
//  ADJAdidController.m
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJAdidController.h"

#import "ADJAdidSubscriber.h"
#import "ADJSingleThreadExecutor.h"
#import "ADJAdidState.h"

#pragma mark Private class
@implementation ADJAdidPublisher @end

@interface ADJAdidController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJAdidStateStorage *storage;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJAdidState *state;
@property (nonnull, readonly, strong, nonatomic) ADJAdidPublisher *adidPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;

@end

@implementation ADJAdidController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    adidStateStorage:(nonnull ADJAdidStateStorage *)adidStateStorage
    threadController:(nonnull ADJThreadController *)threadController
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"AdidController"];
    _storage = adidStateStorage;

    _state = [[ADJAdidState alloc]
              initWithLoggerFactory:loggerFactory
              initialStateData:[adidStateStorage readOnlyStoredDataValue]];

    _adidPublisher = [[ADJAdidPublisher alloc]
                      initWithSubscriberProtocol:@protocol(ADJAdidSubscriber)
                      controller:publisherController];

    _executor = [threadController createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                             sourceLoggerName:self.logger.name];

    return self;
}

#pragma mark Public API
#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if ([sdkResponseData shouldRetry]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithLogger:self.logger
                                          from:@"received accepted response"
                                         block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf receivedSdkResponseWithData:sdkResponseData];
    }];
}

#pragma mark Internal Methods
- (void)receivedSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    ADJAdidStateData *_Nullable updatedStateData =
        [self.state updateStateWithReceivedAdid:sdkResponseData.adid];
    if (updatedStateData == nil) {
        return;
    }

    [self.storage updateWithNewDataValue:updatedStateData];

    [self.adidPublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJAdidSubscriber> _Nonnull subscriber)
     {
        [subscriber onAdidChangeWithValue:updatedStateData.adid];
    }];
}

@end
