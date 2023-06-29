//
//  ADJCoppaState.m
//  Adjust
//
//  Created by Pedro Silva on 28.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJCoppaState.h"

@implementation ADJCoppaStateOutputData
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark - Private constructors
- (nonnull instancetype)
    initWithChangedStateData:(nullable ADJCoppaStateData *)changedStateData
    trackTPSbeforeDeactivate:(BOOL)trackTPSbeforeDeactivate
    deactivateTPSafterTracking:(BOOL)deactivateTPSafterTracking
{
    self = [super init];
    _changedStateData = changedStateData;
    _trackTPSbeforeDeactivate = trackTPSbeforeDeactivate;
    _deactivateTPSafterTracking = deactivateTPSafterTracking;

    return self;
}

@end

@interface ADJCoppaState ()
#pragma mark - Injected dependencies
@property (nonnull, readwrite, strong, nonatomic) ADJCoppaStateData *stateData;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasSdkInit;

@end

@implementation ADJCoppaState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJCoppaStateData *)initialStateData
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"CoppaState"];
    _stateData = initialStateData;

    _hasSdkInit = NO;

    return self;
}

#pragma mark Public API
- (nullable ADJCoppaStateOutputData *)sdkInitWithWasCoppaEnabledByClient:
    (BOOL)wasCoppaEnabledByClient
{
    if (self.hasSdkInit) {
        [self.logger debugDev:@"sdkInit should only be called once"
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }
    self.hasSdkInit = YES;

    if (self.stateData.isCoppaEnabled.boolValue == wasCoppaEnabledByClient) {
        if (wasCoppaEnabledByClient) {
            [self.logger infoClient:@"Coppa compliance will remain enabled, as it was previously"];
        }
        return [[ADJCoppaStateOutputData alloc]
                initWithChangedStateData:nil
                trackTPSbeforeDeactivate:NO
                deactivateTPSafterTracking:wasCoppaEnabledByClient];
    }

    if (wasCoppaEnabledByClient) {
        [self.logger infoClient:
         @"Coppa compliance was previously not enabled, but now it will be"];
    } else {
        [self.logger noticeClient:@"Coppa compliance was previously enabled, but now it will not"];
    }

    self.stateData = [[ADJCoppaStateData alloc] initWithIsCoppaEnabled:
                      [ADJBooleanWrapper instanceFromBool:wasCoppaEnabledByClient]];

    BOOL trackThenDeactivateTPS = self.stateData.isCoppaEnabled.boolValue;
    if (trackThenDeactivateTPS) {
        [self.logger debugDev:@"Will track Coppa disable TPS, since Coppa is being enabled"];
    } else {
        [self.logger debugDev:@"Won't track Coppa disable TPS, since Coppa is not being enabled"];
    }

    return [[ADJCoppaStateOutputData alloc]
            initWithChangedStateData:self.stateData
            trackTPSbeforeDeactivate:trackThenDeactivateTPS
            deactivateTPSafterTracking:trackThenDeactivateTPS];
}

@end
