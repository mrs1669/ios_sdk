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

@interface ADJSdkActiveController ()
// publishers
@property (nonnull, readwrite, strong, nonatomic) ADJSdkActivePublisher *sdkActivePublisher;
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSdkActiveStateStorage *activeStateStorage;
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *clientExecutor;
@property (nonnull, readwrite, strong, nonatomic) ADJSdkActiveState *sdkActiveState;
@property (readwrite, assign, nonatomic) BOOL canPublish;
@end


@implementation ADJSdkActiveController

- (instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                   activeStateStorage:(ADJSdkActiveStateStorage *)activeStateStorage
                       clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                          isForgotten:(BOOL)isForgotten
                   publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry {

    self = [super initWithLoggerFactory:loggerFactory source:@"SdkActiveController"];

    _activeStateStorage = activeStateStorage;
    _clientExecutor = clientExecutor;

    _sdkActivePublisher = [[ADJSdkActivePublisher alloc] init];
    [pubRegistry addPublisher:_sdkActivePublisher];

    _sdkActiveState = [[ADJSdkActiveState alloc] initWithLoggerFactory:loggerFactory
                                                    sdkActiveStateData:[_activeStateStorage readOnlyStoredDataValue]
                                                       isGdprForgotten:isForgotten];
    _canPublish = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}A

- (BOOL)ccTrySdkInit {
    return [self.sdkActiveState trySdkInit];
}

- (BOOL)ccCanPerformActionWithSource:(nonnull NSString *)source
                        errorMessage:(NSString * _Nullable * _Nullable)errorMessage {
    return [self.sdkActiveState canPerformActionWithSource:source errorMessage:errorMessage];
}

- (void)ccInactivateSdk {

    ADJValueWO<ADJSdkActiveStateData *> *_Nonnull changedSdkActiveStateDataWO = [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];

    [self.sdkActiveState inactivateSdkWithActiveStatusEventWO:sdkActiveStatusEventWO
                                            activeStateDataWO:changedSdkActiveStateDataWO];

    [self handleStateSideEffectsWithChangedSdkActiveStateData:changedSdkActiveStateDataWO.changedValue
                                         sdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
                                                       source:@"ccInactivateSdk"];
}

- (void)ccReactivateSdk {

    ADJValueWO<ADJSdkActiveStateData *> *_Nonnull changedSdkActiveStateDataWO = [[ADJValueWO alloc] init];
    ADJValueWO<NSString *> *_Nonnull sdkActiveStatusEventWO = [[ADJValueWO alloc] init];

    [self.sdkActiveState reactivateSdkWithActiveStatusEventWO:sdkActiveStatusEventWO
                                            activeStateDataWO:changedSdkActiveStateDataWO];

    [self handleStateSideEffectsWithChangedSdkActiveStateData:changedSdkActiveStateDataWO.changedValue
                                         sdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
                                                       source:@"ccReactivateSdk"];
}

- (BOOL)ccGdprForgetDevice {

    ADJValueWO<NSString *> * sdkActiveStatusEventWO = [self.sdkActiveState gdprForgottenByClient];
    if (! sdkActiveStatusEventWO) {
        return NO;
    }

    [self handleSdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue source:@"ccGdprForgetDevice"];
    return YES;
}

#pragma mark - ADJGdprForgetSubscriber
- (void)didGdprForget {

    __typeof(self) __weak weakSelf = self;
    [self.clientExecutor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        [strongSelf processGdprForgetEvent];
    } source:@"didGdprForget"];
}

#pragma mark - ADJPublishingGateSubscriber
- (void)ccAllowedToPublishNotifications {

    self.canPublish = YES;
    NSString *sdkActiveStatus = [self.sdkActiveState sdkActiveStatus];
    [self.logger debugDev:@"ccAllowedToPublishNotifications, we can now publish"
                      key:@"sdkActiveStatus"
                    value:sdkActiveStatus];

    [self handleSdkActiveStatusEvent:sdkActiveStatus source:@"ccAllowedToPublishNotifications"];
}


#pragma mark Internal Methods

- (void)handleStateSideEffectsWithChangedSdkActiveStateData:(nullable ADJSdkActiveStateData *)changedSdkActiveStateData
                                       sdkActiveStatusEvent:(nullable NSString *)sdkActiveStatusEvent
                                                     source:(nonnull NSString *)source {
    if (changedSdkActiveStateData != nil) {
        [self.activeStateStorage updateWithNewDataValue:changedSdkActiveStateData];
    }

    [self handleSdkActiveStatusEvent:sdkActiveStatusEvent source:source];
}

- (void)handleSdkActiveStatusEvent:(nullable NSString *)sdkActiveStatusEvent
                            source:(nonnull NSString *)source {
    if (sdkActiveStatusEvent == nil) {
        return;
    }

    if (! self.canPublish) {
        return;
    }

    [self.logger debugDev:@"Publishing Sdk Active Status"
                     from:source
                      key:@"sdkActiveStatusEvent"
                    value:sdkActiveStatusEvent];

    [self.sdkActivePublisher notifySubscribersWithSubscriberBlock:
     ^(id<ADJSdkActiveSubscriber> _Nonnull subscriber) {
        [subscriber ccSdkActiveWithStatus:sdkActiveStatusEvent];
    }];
}

- (void)processGdprForgetEvent {
    ADJValueWO<NSString *> * sdkActiveStatusEventWO = [self.sdkActiveState gdprForgottenByEvent];
    [self handleSdkActiveStatusEvent:sdkActiveStatusEventWO.changedValue
                              source:@"didGdprForget"];
}

@end
