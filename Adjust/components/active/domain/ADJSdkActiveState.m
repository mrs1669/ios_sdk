//
//  ADJSdkActiveState.m
//  AdjustV5
//
//  Created by Pedro S. on 28.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSdkActiveState.h"

#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public constants
ADJSdkActiveStatus const ADJSdkActiveStatusActive = @"ACTIVE";
ADJSdkActiveStatus const ADJSdkActiveStatusInactive = @"INACTIVE";
ADJSdkActiveStatus const ADJSdkActiveStatusForgotten = @"FORGOTTEN";

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

    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self sdkActiveStatus];
    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize, but it was forgotten to GDPR law."
         " It will remain inactive"];
    } else if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize, but will be inactive."
         " It can be reactivated"];
    } else if (ADJSdkActiveStatusActive == sdkActiveStatus) {
        [self.logger infoClient:@"Sdk will initialize"];
    } else {
        [self.logger debugDev:@"Found unknown sdk active status"
                          key:@"sdkActiveStatus"
                        value:sdkActiveStatus
                    issueType:ADJIssueLogicError];
    }

    self.hasSdkInit = YES;

    return YES;
}

- (nullable NSString *)canPerformActionOrElseMessageWithClientSource:
    (nonnull NSString *)clientSource
{
    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        return [ADJUtilF logMessageAndParamsFormat:
                [self.logger errorClient:@"Sdk cannot perform action."
                 " Sdk was forgotten in accordance with GDPR law"
                                    from:clientSource]];
    }

    if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        return [ADJUtilF logMessageAndParamsFormat:
                [self.logger errorClient:@"Sdk cannot perform action. Sdk is currently inactive"
                                    from:clientSource]];
    }

    return nil;
}

- (nullable ADJActivityStateOutputData *)inactivateSdk {
    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger errorClient:
         @"Sdk was already inactive by being forgotten in accordance to GDPR law"];
        return nil;
    }

    if (ADJSdkActiveStatusInactive == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be inactivated, since it already inactive"];
        return nil;
    }

    self.sdkActiveStateData = [[ADJSdkActiveStateData alloc] initWithInactiveSdk];

    [self.logger infoClient:@"Sdk will be inactivated"];

    return [[ADJActivityStateOutputData alloc] initWithStateData:self.sdkActiveStateData
                                                 sdkActiveStatus:ADJSdkActiveStatusInactive];
}
- (nullable ADJActivityStateOutputData *)reactivateSdk {
    ADJSdkActiveStatus _Nonnull sdkActiveStatus = [self sdkActiveStatus];

    if (ADJSdkActiveStatusForgotten == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be reactivated."
         " This device was forgotten in accordance to GDPR law"];
        return nil;
    }

    if (ADJSdkActiveStatusActive == sdkActiveStatus) {
        [self.logger errorClient:@"Sdk cannot be reactivated, since it already active"];
        return nil;
    }

    self.sdkActiveStateData = [[ADJSdkActiveStateData alloc] initWithActiveSdk];

    [self.logger infoClient:@"Sdk will be reactivated"];

    return [[ADJActivityStateOutputData alloc] initWithStateData:self.sdkActiveStateData
                                                 sdkActiveStatus:ADJSdkActiveStatusActive];
}

- (nullable ADJActivityStateOutputData *)forgottenFromClient {
    if (self.isSdkForgotten) {
        [self.logger errorClient:@"Sdk was already forgotten in accordance with GDPR law"];
        return nil;
    }

    [self.logger infoClient:@"Sdk will be forgotten in accordance with GDPR law"];

    self.isSdkForgotten = YES;

    return [[ADJActivityStateOutputData alloc] initWithSdkActiveStatus:ADJSdkActiveStatusForgotten];

}
- (nullable ADJActivityStateOutputData *)forgottenFromEvent {
    if (self.isSdkForgotten) {
        return nil;
    }

    self.isSdkForgotten = YES;

    return [[ADJActivityStateOutputData alloc] initWithSdkActiveStatus:ADJSdkActiveStatusForgotten];
}

- (nonnull ADJSdkActiveStatus)sdkActiveStatus {
    if (self.isSdkForgotten) {
        return ADJSdkActiveStatusForgotten;
    }

    if (! self.sdkActiveStateData.isSdkActive) {
        return ADJSdkActiveStatusInactive;
    }

    return ADJSdkActiveStatusActive;
}

@end

@implementation ADJActivityStateOutputData
- (nonnull instancetype)initWithStateData:(nonnull ADJSdkActiveStateData *)stateData
                          sdkActiveStatus:(nonnull ADJSdkActiveStatus)sdkActiveStatus
{
    return [self initWithNullableStateData:stateData sdkActiveStatus:sdkActiveStatus];
}
- (nonnull instancetype)initWithSdkActiveStatus:(nonnull ADJSdkActiveStatus)sdkActiveStatus {
    return [self initWithNullableStateData:nil sdkActiveStatus:sdkActiveStatus];

}

- (nonnull instancetype)initWithNullableStateData:(nullable ADJSdkActiveStateData *)stateData
                                  sdkActiveStatus:(nullable ADJSdkActiveStatus)sdkActiveStatus
{
    self = [super init];
    _changedStateData = stateData;
    _sdkActiveStatus = sdkActiveStatus;
    return self;
}

@end
