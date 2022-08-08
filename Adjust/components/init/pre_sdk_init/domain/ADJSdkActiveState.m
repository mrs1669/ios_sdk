//
//  ADJSdkActiveState.m
//  AdjustV5
//
//  Created by Pedro S. on 28.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSdkActiveState.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJSdkActiveStatusActive = @"ACTIVE";
NSString *const ADJSdkActiveStatusInactive = @"INACTIVE";
NSString *const ADJSdkActiveStatusForgotten = @"FORGOTTEN";

@interface ADJSdkActiveState ()
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isSdkForgotten;
@property (readwrite, assign, nonatomic) BOOL canPublish;
@property (readwrite, assign, nonatomic) BOOL hasSdkInit;
@property (readwrite, assign, nonatomic) BOOL askedToForget;

@end

@implementation ADJSdkActiveState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                              isGdprForgotten:(BOOL)isGdprForgotten
{
    self = [super initWithLoggerFactory:loggerFactory source:@"5SdkActiveState"];

    _isSdkForgotten = isGdprForgotten;

    _canPublish = NO;

    _hasSdkInit = NO;

    _askedToForget = NO;

    return self;
}

#pragma mark Public API
- (BOOL)sdkInitWithCurrentSdkActiveStateData:(nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
                             adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger {
    if (self.hasSdkInit) {
        [adjustApiLogger error:@"Sdk is already init"];
        return NO;
    }

    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    if (ADJSdkActiveStatusForgotten == currentSdkActiveStatus) {
        [adjustApiLogger info:@"Sdk will initialize, but it was forgotten to GDPR law."
            " It will remain inactive"];
    }
    if (ADJSdkActiveStatusInactive == currentSdkActiveStatus) {
        [adjustApiLogger info:@"Sdk will initialize, but will be inactive."
            " It can be reactivated"];
    }
    if (ADJSdkActiveStatusActive == currentSdkActiveStatus) {
        [adjustApiLogger info:@"Sdk will initialize"];
    }

    self.hasSdkInit = YES;

    return YES;
}

- (void)
    inactivateSdkWithCurrentSdkActiveStateData:
        (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
    sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
    changedSdkActiveStateDataWO:
        (nonnull ADJValueWO<ADJSdkActiveStateData *> *)changedSdkActiveStateDataWO
    adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger
{
    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    if (ADJSdkActiveStatusForgotten == currentSdkActiveStatus) {
        [adjustApiLogger error:@"Sdk was already inactive by being"
            " forgotten in accordance to GDPR law"];
        return;
    }

    if (ADJSdkActiveStatusInactive == currentSdkActiveStatus) {
        [adjustApiLogger error:@"Sdk cannot be inactivated, since it already inactive"];
        return;
    }

    [adjustApiLogger info:@"Sdk will be inactivated"];

    ADJSdkActiveStateData *_Nonnull inactiveSdkStateData =
        [[ADJSdkActiveStateData alloc] initWithInactiveSdk];
    [changedSdkActiveStateDataWO setNewValue:inactiveSdkStateData];

    if (self.canPublish) {
        [sdkActiveStatusEventWO setNewValue:ADJSdkActiveStatusInactive];
    }
}

- (void)
    reactivateSdkWithCurrentSdkActiveStateData:
        (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
    sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
    changedSdkActiveStateDataWO:
        (nonnull ADJValueWO<ADJSdkActiveStateData *> *)changedSdkActiveStateDataWO
    adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger
{
    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    if (ADJSdkActiveStatusForgotten == currentSdkActiveStatus) {
        [adjustApiLogger error:@"Sdk cannot be reactivated"
            " This device was forgotten in accordance to GDPR law"];
        return;
    }

    if (ADJSdkActiveStatusActive == currentSdkActiveStatus) {
        [adjustApiLogger error:@"Sdk cannot be reactivated, since it already inactive"];
        return;
    }

    [adjustApiLogger info:@"Sdk will be reactivated"];

    ADJSdkActiveStateData *_Nonnull activeSdkStateData =
        [[ADJSdkActiveStateData alloc] initWithActiveSdk];
    [changedSdkActiveStateDataWO setNewValue:activeSdkStateData];

    if (self.canPublish) {
        [sdkActiveStatusEventWO setNewValue:ADJSdkActiveStatusActive];
    }
}

- (nonnull NSString *)
    canPerformActiveActionWithCurrentSdkActiveStateData:
        (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
    source:(nonnull NSString *)source
{
    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    if (ADJSdkActiveStatusForgotten == currentSdkActiveStatus) {
        return [NSString stringWithFormat:
                    @"Sdk cannot perform %@. Sdk was forgotten in accordance to GDPR law",
                    source];
    }

    if (ADJSdkActiveStatusInactive == currentSdkActiveStatus) {
        return [NSString stringWithFormat:
                    @"Sdk cannot perform %@. Sdk is currently inactive",
                    source];
    }

    return nil;
}

- (void)
    canNowPublishWithCurrentSdkActiveStateData:
        (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
    sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
{
    self.canPublish = YES;

    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    [self.logger debug:@"Sdk Active State: %@, when can now publish", currentSdkActiveStatus];

    [sdkActiveStatusEventWO setNewValue:currentSdkActiveStatus];
}

- (void)
    gdprForgetEventReceivedWithSdkActiveStatusEventWO:
        (nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
{
    // gdprForgetStatus value is ignored since
    //  both possible values: ASKED_TO_FORGET or FORGOTTEN_BY_BACKEND
    //  are the same for SdkActiveStatus purpose
    self.isSdkForgotten = YES;

    // nothing to publish if it already did previously
    if (self.askedToForget) {
        return;
    }

    if (self.canPublish) {
        [sdkActiveStatusEventWO setNewValue:ADJSdkActiveStatusForgotten];
    }
}

- (BOOL)
    tryForgetDeviceWithCurrentSdkActiveStateData:
        (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
    sdkActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)sdkActiveStatusEventWO
    adjustApiLogger:(nonnull ADJLogger *)adjustApiLogger
{
    NSString *_Nonnull currentSdkActiveStatus =
        [self currentSdkActiveStatusWithStateData:currentSdkActiveStateData];

    if (currentSdkActiveStatus == ADJSdkActiveStatusForgotten) {
        [adjustApiLogger error:@"Sdk was already forgotten in accordance to GDPR law"];
        return NO;
    }

    [adjustApiLogger info:@"Sdk will be forgotten in accordance to GDPR law"];

    self.isSdkForgotten = YES;

    self.askedToForget = YES;

    if (self.canPublish) {
        [sdkActiveStatusEventWO setNewValue:ADJSdkActiveStatusForgotten];
    }

    return YES;
}

#pragma mark Internal Methods
- (nonnull NSString *)currentSdkActiveStatusWithStateData:
    (nonnull ADJSdkActiveStateData *)currentSdkActiveStateData
{
    if (self.isSdkForgotten) {
        return ADJSdkActiveStatusForgotten;
    }

    if (! currentSdkActiveStateData.isSdkActive) {
        return ADJSdkActiveStatusInactive;
    }

    return ADJSdkActiveStatusActive;
}

@end
