//
//  ADJSdkActiveController.m
//  Adjust
//
//  Created by Genady Buchatsky on 11.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkActiveController.h"
#import "ADJSdkActiveSubscriber.h"
#import "ADJSdkActiveState.h"

#pragma mark Private class
@implementation ADJSdkActivePublisher @end

#pragma mark Fields
@interface ADJSdkActiveController ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveStateStorage *storage;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveState *sdkActiveState;
@property (nonnull, readonly, strong, nonatomic) ADJSdkActivePublisher *sdkActivePublisher;
@property (readwrite, assign, nonatomic) BOOL canPublish;

@end

@implementation ADJSdkActiveController
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    activeStateStorage:(nonnull ADJSdkActiveStateStorage *)activeStateStorage
    clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
    isForgotten:(BOOL)isForgotten
    publisherController:(nonnull ADJPublisherController *)publisherController
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"SdkActiveController"];
    _storage = activeStateStorage;
    _clientExecutor = clientExecutor;

    _sdkActivePublisher = [[ADJSdkActivePublisher alloc]
                           initWithSubscriberProtocol:@protocol(ADJSdkActiveSubscriber)
                           controller:publisherController];

    _sdkActiveState = [[ADJSdkActiveState alloc]
                       initWithLoggerFactory:loggerFactory
                       sdkActiveStateData:[activeStateStorage readOnlyStoredDataValue]
                       isGdprForgotten:isForgotten];

    _canPublish = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (BOOL)ccTrySdkInit {
    return [self.sdkActiveState trySdkInit];
}

- (nullable ADJResultFail *)ccCanPerformClientAction {
    return [self.sdkActiveState canPerformActionClientAction];
}

- (void)ccInactivateSdk {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState inactivateSdk];
    [self ccHandleSideEffectsWithOutputData:output from:@"ccInactivateSdk"];
}

- (void)ccReactivateSdk {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState reactivateSdk];
    [self ccHandleSideEffectsWithOutputData:output from:@"ccReactivateSdk"];
}

- (BOOL)ccGdprForgetDevice {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState forgottenFromClient];
    return [self ccHandleSideEffectsWithOutputData:output from:@"ccGdprForgetDevice"];
}

#pragma mark - ADJGdprForgetSubscriber
- (void)didGdprForget {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithLogger:self.logger
                                                    from:@"didGdprForget"
                                                   block:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJActivityStateOutputData *_Nullable outputData =
            [strongSelf.sdkActiveState forgottenFromEvent];

        [strongSelf ccHandleSideEffectsWithOutputData:outputData from:@"didGdprForget"];
    }];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    self.canPublish = YES;

    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self.sdkActiveState sdkActiveStatus];

    [self ccHandleEventWithSdkActiveStatus:sdkActiveStatus
                                      from:@"ccAllowedToPublishNotifications"];
}

#pragma mark Internal Methods
- (BOOL)ccHandleSideEffectsWithOutputData:(nullable ADJActivityStateOutputData *)outputData
                                     from:(nonnull NSString *)from
{
    if (outputData == nil) { return NO; }

    [self ccHandleStateUpdateWithChangedStateData:outputData.changedStateData];

    [self ccHandleEventWithSdkActiveStatus:outputData.sdkActiveStatus
                                      from:from];

    return YES;
}

- (void)ccHandleStateUpdateWithChangedStateData:(nullable ADJSdkActiveStateData *)stateData {
    if (stateData == nil) { return; }

    [self.storage updateWithNewDataValue:stateData];
}

- (void)ccHandleEventWithSdkActiveStatus:(nullable ADJSdkActiveStatus)sdkActiveStatus
                                    from:(nonnull NSString *)from
{
    if (sdkActiveStatus == nil) { return; }
    if (! self.canPublish) { return; }

    [self.logger debugDev:@"Publishing Sdk Active Status"
                     from:from
                      key:@"sdkActiveStatusEvent"
              stringValue:sdkActiveStatus];

    [self.sdkActivePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkActiveSubscriber> _Nonnull subscriber) {
        [subscriber ccSdkActiveWithStatus:sdkActiveStatus];
    }];
}

@end
