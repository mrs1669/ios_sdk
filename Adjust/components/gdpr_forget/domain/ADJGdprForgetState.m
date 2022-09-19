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
#pragma mark - Public constants
NSString *const ADJGdprForgetStatusAskedToForget = @"AskedToForget";
NSString *const ADJGdprForgetStatusForgottenByBackend = @"ForgottenByBackend";

@interface ADJGdprForgetState ()
#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isOnForeground;
@property (readwrite, assign, nonatomic) BOOL hasSdkInit;
@property (readwrite, assign, nonatomic) BOOL canPublish;
@property (readwrite, assign, nonatomic) BOOL hasAppStart;

@end

@implementation ADJGdprForgetState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"GdprForgetState"];

    _isOnForeground = ADJIsSdkInForegroundWhenStarting;

    _hasSdkInit = NO;

    _canPublish = NO;

    _hasAppStart = NO;

    return self;
}

#pragma mark Public API
- (BOOL)shouldStartTrackingWhenForgottenByClientWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                        changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                             gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    if (! [self canChangeToAskedToForgetWithCurrentStateData:currentGdprForgetStateData]) {
        return NO;
    }

    ADJGdprForgetStateData *_Nullable gdprForgetStateData =
    [self changeToAskedToForgetWithChangedGdprForgetStateDataWO:changedGdprForgetStateDataWO
                                        gdprForgetStatusEventWO:gdprForgetStatusEventWO];

    return [self shouldStartTrackingWithLatestStateData:gdprForgetStateData];
}

- (BOOL)shouldStartTrackingWhenSdkInitWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                   gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    if (self.hasSdkInit) {
        [self.logger debug:@"Sdk init already happened"];
        return NO;
    }

    self.hasSdkInit = YES;

    [self tryChangeToAppStart];

    [self notifyGdprForgetStateEventWithCurrentStateData:currentGdprForgetStateData
                                 gdprForgetStatusEventWO:gdprForgetStatusEventWO];

    return [self shouldStartTrackingWithLatestStateData:currentGdprForgetStateData];
}

- (void)canStartPublish {
    self.canPublish = YES;
}

- (BOOL)shouldStartTrackingWhenAppWentToTheForegroundWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData {
    if (self.isOnForeground) {
        [self.logger debug:@"Already in the foreground"];
        return NO;
    }

    self.isOnForeground = YES;

    [self tryChangeToAppStart];

    return [self shouldStartTrackingWithLatestStateData:currentGdprForgetStateData];
}

- (void)appWentToTheBackground {
    if (! self.isOnForeground) {
        [self.logger debug:@"Already in the background"];
        return;
    }
    self.isOnForeground = NO;

    [self tryChangeToAppStart];
}

- (BOOL)shouldStopTrackingWhenReceivedOptOutWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                    changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                         gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    BOOL canChangeToForgottenByBackend =
    [self canChangeToForgottenByBackendWithCurrentStateData:currentGdprForgetStateData
                                                     source:@"ReceivedOptOutInSdkResponse"];

    if (! canChangeToForgottenByBackend) {
        // should still stop when received OptOut in SdkResponse
        return YES;
    }

    [self changeToForgottenByBackendWithCurrentStateData:currentGdprForgetStateData
                            changedGdprForgetStateDataWO:changedGdprForgetStateDataWO
                                 gdprForgetStatusEventWO:gdprForgetStatusEventWO];

    return YES;
}

- (BOOL)shouldStopTrackingWhenReceivedProcessedGdprResponseWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                                   changedGdprForgetStateDataWO:
(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                                        gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    if (! [self
           canChangeToForgottenByBackendWithCurrentStateData:currentGdprForgetStateData
           source:@"ReceivedProcessedGdprResponse"])
    {
        // should still stop when received processed GdprResponse
        return YES;
    }

    [self changeToForgottenByBackendWithCurrentStateData:currentGdprForgetStateData
                            changedGdprForgetStateDataWO:changedGdprForgetStateDataWO
                                 gdprForgetStatusEventWO:gdprForgetStatusEventWO];

    return YES;
}

#pragma mark Internal Methods
- (BOOL)canChangeToAskedToForgetWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData {
    if ([currentGdprForgetStateData isNotForgotten]) {
        return YES;
    }

    if (currentGdprForgetStateData.forgottenByBackend) {
        [self.logger info:@"Cannot change to AskedToForget,"
         " since it was already forgotten by the backend"];
    } else {
        [self.logger info:@"Already in AskedToForget"];
    }

    return NO;
}

- (nullable ADJGdprForgetStateData *)changeToAskedToForgetWithChangedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                                                                   gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    ADJGdprForgetStateData *_Nonnull gdprAskedToForgetData =
    [[ADJGdprForgetStateData alloc] initAskedButNotForgotten];

    [changedGdprForgetStateDataWO setNewValue:gdprAskedToForgetData];

    [gdprForgetStatusEventWO setNewValue:ADJGdprForgetStatusAskedToForget];

    return gdprAskedToForgetData;
}

- (BOOL)shouldStartTrackingWithLatestStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData {
    if (! self.hasSdkInit) {
        [self.logger debug:@"Cannot start tracking GDPR forget before sdk init"];
        return NO;
    }

    if (! self.hasAppStart) {
        [self.logger debug:@"Cannot start tracking GDPR forget before app start"];
        return NO;
    }

    if ([currentGdprForgetStateData isNotForgotten]) {
        [self.logger debug:@"Cannot start tracking GDPR forget when not forgotten"];
        return NO;
    }

    if (currentGdprForgetStateData.forgottenByBackend) {
        [self.logger debug:@"Cannot start tracking GDPR forget"
         " when already forgotten in backend"];
        return NO;
    }

    [self.logger debug:@"Can start tracking GDPR forget"];

    return YES;
}

- (void)tryChangeToAppStart {
    if (self.hasAppStart) {
        return;
    }

    if (! self.hasSdkInit) {
        return;
    }

    if (! self.isOnForeground) {
        return;
    }

    self.hasAppStart = YES;
}

- (void)notifyGdprForgetStateEventWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                               gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    // nothing to notify when not forgotten
    if ([currentGdprForgetStateData isNotForgotten]) {
        return;
    }

    if (currentGdprForgetStateData.forgottenByBackend) {
        [self notifyGdprForgetStateEventWitStatusWO:gdprForgetStatusEventWO
                              gdprForgetStatusEvent:ADJGdprForgetStatusForgottenByBackend];
    } else {
        [self notifyGdprForgetStateEventWitStatusWO:gdprForgetStatusEventWO
                              gdprForgetStatusEvent:ADJGdprForgetStatusAskedToForget];
    }
}

- (void)notifyGdprForgetStateEventWitStatusWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO
                        gdprForgetStatusEvent:(nonnull NSString *)gdprForgetStatusEvent {
    if (! self.canPublish) {
        return;
    }

    [gdprForgetStatusEventWO setNewValue:gdprForgetStatusEvent];
}

- (BOOL)canChangeToForgottenByBackendWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                                                   source:(nonnull NSString *)source {
    if ([currentGdprForgetStateData isNotForgotten]) {
        [self.logger debug:@"Changing to ForgottenByBackend from %@"
         " while not previously asked by sdk", source];

        return YES;
    }

    if (! currentGdprForgetStateData.forgottenByBackend) {
        [self.logger debug:@"Changing to ForgottenByBackend from %@", source];

        return YES;
    }

    [self.logger debug:@"Cannot change to ForgottenByBackend,"
     " since it was already forgotten by the backend"];

    return NO;
}

- (void)changeToForgottenByBackendWithCurrentStateData:(nonnull ADJGdprForgetStateData *)currentGdprForgetStateData
                          changedGdprForgetStateDataWO:(nonnull ADJValueWO<ADJGdprForgetStateData *> *)changedGdprForgetStateDataWO
                               gdprForgetStatusEventWO:(nonnull ADJValueWO<NSString *> *)gdprForgetStatusEventWO {
    ADJGdprForgetStateData *_Nonnull gdprForgottenByBackend =
    [[ADJGdprForgetStateData alloc]
     initForgottenByBackendWithAskedToForgetBySdk:
         currentGdprForgetStateData.askedToForgetBySdk];

    [changedGdprForgetStateDataWO setNewValue:gdprForgottenByBackend];

    [self notifyGdprForgetStateEventWitStatusWO:gdprForgetStatusEventWO
                          gdprForgetStatusEvent:ADJGdprForgetStatusForgottenByBackend];
}

@end

