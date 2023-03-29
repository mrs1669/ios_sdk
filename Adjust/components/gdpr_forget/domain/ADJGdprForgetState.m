//
//  ADJGdprForgetState.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetState.h"

#import "ADJConstants.h"

#pragma mark Fields
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJGdprForgetStateData *changedStateData;
 @property (nullable, readonly, strong, nonatomic) ADJGdprForgetStatus status;
 @property (readonly, assign, nonatomic) BOOL startTracking;
 */

@implementation ADJGdprForgetStateOutputData
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark - Private constructors
- (nonnull instancetype)
    initWithChangedStateData:(nullable ADJGdprForgetStateData *)changedStateData
    status:(nullable ADJGdprForgetStatus)status
    startTracking:(BOOL)startTracking
{
    self = [super init];

    _changedStateData = changedStateData;
    _status = status;
    _startTracking = startTracking;

    return self;
}

@end

@interface ADJGdprForgetState ()
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL hasAppStart;
@property (nonnull, readwrite, strong, nonatomic) ADJGdprForgetStateData *stateData;


@end

@implementation ADJGdprForgetState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJGdprForgetStateData *)initialStateData
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"GdprForgetState"];
    _stateData = initialStateData;

    _isOnForeground = ADJIsSdkInForegroundWhenStarting;

    _hasAppStart = NO;

    return self;
}

#pragma mark Public API
- (nullable ADJGdprForgetStateOutputData *)forgottenByClient {
    if ([self.stateData isForgotten]) {
        if (self.stateData.forgottenByBackend) {
            [self.logger debugDev:
                @"Cannot change to AskedToForget, since it was already forgotten by the backend"];
        } else {
            [self.logger debugDev:@"Already in AskedToForget"];
        }

        return nil;
    }

    self.stateData = [[ADJGdprForgetStateData alloc] initAskedButNotForgotten];

    ADJGdprForgetStatus _Nonnull statusAskedToForget = ADJGdprForgetStatusAskedToForget;

    BOOL startTracking = [self shouldStartTracking];

    return [[ADJGdprForgetStateOutputData alloc]
            initWithChangedStateData:self.stateData
            status:statusAskedToForget
            startTracking:startTracking];
}

- (nullable ADJGdprForgetStateOutputData *)appStart {
    if (self.hasAppStart) {
        [self.logger debugDev:@"App start already happened"
                    issueType:ADJIssueUnexpectedInput];
        return nil;
    }
    self.hasAppStart = YES;

    if ([self shouldStartTracking]) {
        return [[ADJGdprForgetStateOutputData alloc]
                initWithChangedStateData:nil
                status:nil
                startTracking:YES];
    } else {
        return nil;
    }
}

- (nullable ADJGdprForgetStateOutputData *)receivedOptOut {
    return [self tryToChangeToForgottenByBackendFrom:@"receivedOptOut"];
    // TODO: Should tell tracker to stop trying to track?
}

- (nullable ADJGdprForgetStateOutputData *)receivedAcceptedGdprResponse {
    return [self tryToChangeToForgottenByBackendFrom:@"receivedAcceptedGdprResponse"];
}

#pragma mark Internal Methods
- (BOOL)shouldStartTracking {
    if (! self.hasAppStart) {
        [self.logger debugDev:@"Cannot start tracking GDPR forget before app start"];
        return NO;
    }

    if (! [self.stateData isForgotten]) {
        [self.logger debugDev:@"Cannot start tracking GDPR forget when not forgotten"];
        return NO;
    }

    if (self.stateData.forgottenByBackend) {
        [self.logger debugDev:
         @"Cannot start tracking GDPR forget when already forgotten in backend"];
        return NO;
    }

    [self.logger debugDev:@"Can start tracking GDPR forget"];

    return YES;
}

- (nullable ADJGdprForgetStateOutputData *)
    tryToChangeToForgottenByBackendFrom:(nonnull NSString *)from
{
    if (self.stateData.forgottenByBackend) {
        [self.logger debugDev:
            @"Cannot change to ForgottenByBackend, since it was already forgotten by the backend"
                         from:from];
        return nil;
    }

    [self.logger debugDev:@"Changing to ForgottenByBackend"
                     from:from];

    self.stateData = [[ADJGdprForgetStateData alloc]
                      initForgottenByBackendWithAskedToForgetBySdk:
                          self.stateData.askedToForgetBySdk];

    return [[ADJGdprForgetStateOutputData alloc]
            initWithChangedStateData:self.stateData
            status:ADJGdprForgetStatusForgottenByBackend
            startTracking:NO];
}

@end
