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
@property (readwrite, assign, nonatomic) BOOL hasSdkInit;
@property (nonnull, readwrite, strong, nonatomic) ADJSdkActiveStateData *sdkActiveStateData;
@end

@implementation ADJSdkActiveState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                           sdkActiveStateData:(nonnull ADJSdkActiveStateData *)sdkActiveStateData
                              isGdprForgotten:(BOOL)isGdprForgotten {

    self = [super initWithLoggerFactory:loggerFactory source:@"SdkActiveState"];

    _sdkActiveStateData = sdkActiveStateData;
    _isSdkForgotten = isGdprForgotten;
    _hasSdkInit = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (BOOL)trySdkInit {

    if (self.hasSdkInit) {
        [self.logger noticeClient:@"Sdk is already init"];
        return NO;
    }

    NSString *_Nonnull sdkActiveStatus = [self sdkActiveStatus];
    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize, but it was forgotten to GDPR law. It will remain inactive"];
    } else if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize, but will be inactive. It can be reactivated"];
    } else if (ADJSdkActiveStatusActive == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize"];
    } else {
        NSString * errReason = [NSString stringWithFormat:@"Found unknown sdk active status:[%@]", sdkActiveStatus];
        @throw [NSException exceptionWithName:@"Unknown Sdk Active status."
                                       reason:errReason
                                     userInfo:nil];
    }

    self.hasSdkInit = YES;

    return YES;
}

- (void)inactivateSdkWithActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)activeStatusEventWO
                           activeStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)activeStateDataWO {

    NSString *_Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk was already inactive by being forgotten in accordance to GDPR law"];
        return;
    }

    if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be inactivated, since it already inactive"];
        return;
    }

    [self.logger infoClient:@"Sdk will be inactivated"];

    ADJSdkActiveStateData *_Nonnull inactiveSdkStateData = [[ADJSdkActiveStateData alloc] initWithInactiveSdk];
    [activeStateDataWO setNewValue:inactiveSdkStateData];
    [activeStatusEventWO setNewValue:ADJSdkActiveStatusInactive];

    // Update local Active State Data
    self.sdkActiveStateData = inactiveSdkStateData;

}

- (void)reactivateSdkWithActiveStatusEventWO:(nonnull ADJValueWO<NSString *> *)activeStatusEventWO
                           activeStateDataWO:(nonnull ADJValueWO<ADJSdkActiveStateData *> *)activeStateDataWO {

    NSString *_Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be reactivated. This device was forgotten in accordance to GDPR law"];
        return;
    }

    if (ADJSdkActiveStatusActive == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be reactivated, since it already active"];
        return;
    }

    [self.logger infoClient:@"Sdk will be reactivated"];

    ADJSdkActiveStateData *_Nonnull activeSdkStateData = [[ADJSdkActiveStateData alloc] initWithActiveSdk];
    [activeStateDataWO setNewValue:activeSdkStateData];
    [activeStatusEventWO setNewValue:ADJSdkActiveStatusActive];

    // Update local Active State Data
    self.sdkActiveStateData = activeSdkStateData;
}

- (BOOL)canPerformActionWithSource:(nonnull NSString *)source
                      errorMessage:(NSString * _Nullable * _Nullable)errorMessage {

    NSString *_Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        if (errorMessage) {
            *errorMessage = [NSString stringWithFormat:@"Sdk cannot perform %@. Sdk was forgotten in accordance with GDPR law",source];
        }
        return NO;
    }

    if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        if (errorMessage) {
            *errorMessage = [NSString stringWithFormat:@"Sdk cannot perform %@. Sdk is currently inactive", source];
        }
        return NO;
    }

    return YES;
}

- (nullable ADJValueWO<NSString *> *)gdprForgottenByEvent {

    if (self.isSdkForgotten) {
        return nil;
    }
    
    self.isSdkForgotten = YES;

    ADJValueWO<NSString *> *_Nonnull activeStatusEventWO = [[ADJValueWO alloc] init];
    [activeStatusEventWO setNewValue:ADJSdkActiveStatusForgotten];
    return activeStatusEventWO;
}

- (nullable ADJValueWO<NSString *> *)gdprForgottenByClient {

    if (self.isSdkForgotten) {
        [self.logger errorClient:@"Sdk was already forgotten in accordance with GDPR law"];
        return nil;
    }

    [self.logger infoClient:@"Sdk will be forgotten in accordance with GDPR law"];
    self.isSdkForgotten = YES;

    ADJValueWO<NSString *> *_Nonnull activeStatusEventWO = [[ADJValueWO alloc] init];
    [activeStatusEventWO setNewValue:ADJSdkActiveStatusForgotten];
    return activeStatusEventWO;
}

- (nonnull NSString *)sdkActiveStatus {
    if (self.isSdkForgotten) {
        return ADJSdkActiveStatusForgotten;
    }

    if (! self.sdkActiveStateData.isSdkActive) {
        return ADJSdkActiveStatusInactive;
    }

    return ADJSdkActiveStatusActive;
}



@end

