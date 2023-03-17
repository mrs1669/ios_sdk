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
    self = [super initWithLoggerFactory:loggerFactory source:@"SdkActiveController"];
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

- (BOOL)ccCanPerformActionWithClientSource:(nonnull NSString *)clientSource {
    return [self ccCanPerformActionOrElseMessageWithClientSource:clientSource] == nil;
}

- (nullable NSString *)ccCanPerformActionOrElseMessageWithClientSource:
    (nonnull NSString *)clientSource
{
    return [self.sdkActiveState canPerformActionOrElseMessageWithClientSource:clientSource];
}

- (void)ccInactivateSdk {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState inactivateSdk];
    [self ccHandleSideEffectsWithOutputData:output source:@"ccInactivateSdk"];
}

- (void)ccReactivateSdk {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState reactivateSdk];
    [self ccHandleSideEffectsWithOutputData:output source:@"ccReactivateSdk"];
}

- (BOOL)ccGdprForgetDevice {
    ADJActivityStateOutputData *_Nullable output = [self.sdkActiveState forgottenFromClient];
    return [self ccHandleSideEffectsWithOutputData:output source:@"ccGdprForgetDevice"];
}

#pragma mark - ADJGdprForgetSubscriber
- (void)didGdprForget {
    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        ADJActivityStateOutputData *_Nullable outputData =
            [strongSelf.sdkActiveState forgottenFromEvent];

        [strongSelf ccHandleSideEffectsWithOutputData:outputData source:@"didGdprForget"];
    } source:@"didGdprForget"];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {
    self.canPublish = YES;

    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self.sdkActiveState sdkActiveStatus];

    [self ccHandleEventWithSdkActiveStatus:sdkActiveStatus
                                    source:@"ccAllowedToPublishNotifications"];
}

#pragma mark Internal Methods
- (BOOL)ccHandleSideEffectsWithOutputData:(nullable ADJActivityStateOutputData *)outputData
                                   source:(nonnull NSString *)source
{
    if (outputData == nil) { return NO; }

    [self ccHandleStateUpdateWithChangedStateData:outputData.changedStateData
                                           source:source];

    [self ccHandleEventWithSdkActiveStatus:outputData.sdkActiveStatus
                                    source:source];

    return YES;
}

- (void)ccHandleStateUpdateWithChangedStateData:(nullable ADJSdkActiveStateData *)stateData
                                         source:(nonnull NSString *)source
{
    if (stateData == nil) { return; }

    [self.storage updateWithNewDataValue:stateData];
}

- (void)ccHandleEventWithSdkActiveStatus:(nullable ADJSdkActiveStatus)sdkActiveStatus
                                  source:(nonnull NSString *)source
{
    if (sdkActiveStatus == nil) { return; }
    if (! self.canPublish) { return; }

    [self.logger debugDev:@"Publishing Sdk Active Status"
                     from:source
                      key:@"sdkActiveStatusEvent"
                    value:sdkActiveStatus];

    [self.sdkActivePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkActiveSubscriber> _Nonnull subscriber) {
        [subscriber ccSdkActiveWithStatus:sdkActiveStatus];
    }];
}

@end