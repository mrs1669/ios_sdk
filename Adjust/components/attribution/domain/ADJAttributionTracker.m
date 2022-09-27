//
//  ADJAttributionTracker.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionTracker.h"

#import "ADJConstants.h"
#import "ADJConstantsParam.h"
#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJAskingAttributionStatusFromBackend = @"FromBackend";
NSString *const ADJAskingAttributionStatusFromSdk = @"FromSdk";
NSString *const ADJAskingAttributionStatusFromBackendAndSdk = @"FromBackendAndSdk";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;
 */

@interface ADJAttributionTracker ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJBackoffStrategy *backoffStrategy;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isInDelay;
@property (readwrite, assign, nonatomic) BOOL isSending;
@property (readwrite, assign, nonatomic) BOOL isSdkPaused;
@property (nullable, readwrite, strong, nonatomic) NSString *askingAttribution;
@property (nonnull, readwrite, strong, nonatomic) ADJTallyCounter *retriesSinceLastSuccessSend;
@property (nullable, readwrite, strong, nonatomic) ADJAttributionPackageData *attributionPackageToSend;

@end

@implementation ADJAttributionTracker
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                   attributionBackoffStrategy:(nonnull ADJBackoffStrategy *)attributionBackoffStrategy {
    self = [super initWithLoggerFactory:loggerFactory source:@"AttributionTracker"];
    _backoffStrategy = attributionBackoffStrategy;
    
    _isInDelay = NO;
    
    _isSending = NO;
    
    _isSdkPaused = ADJIsSdkPausedWhenStarting;
    
    _retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];
    
    _askingAttribution = nil;
    
    _attributionPackageToSend = nil;
    
    return self;
}

#pragma mark Public API
- (BOOL)canSendWhenAskingWithAskingAttribution:(nonnull NSString *)askingAttribution {
    self.askingAttribution = askingAttribution;
    
    return [self tryToSend];
}

- (void)stopAsking {
    self.askingAttribution = nil;
}

- (BOOL)sendWhenSdkResumingSending {
    self.isSdkPaused = NO;
    
    return [self tryToSend];
}

- (void)pauseSending {
    self.isSdkPaused = YES;
}

- (BOOL)sendWhenDelayEnded {
    self.isInDelay = NO;
    
    return [self tryToSend];
}

- (nullable ADJDelayData *)delaySendingWhenReceivedAttributionResponseWithData:(nonnull ADJAttributionResponseData *)attributionResponse {
    // received attribution response implies that is no longer sending
    self.isSending = NO;
    
    if (attributionResponse.shouldRetry) {
        // Unlike other 'Tracker' classes it won't be in delay here
        //  since, it could be in delay from the state due to ask_in
        //  instead of just be in delay because it should retry the request
        
        [self.logger debug:@"Retry with delay because of not accepted attribution response"];
        return [self delayDataWithRetryIn:attributionResponse.retryIn];
    }
    
    [self.logger debug:@"Not retrying because of accepted attribution response"];
    
    self.retriesSinceLastSuccessSend = [ADJTallyCounter instanceStartingAtZero];
    
    // remove previous attempted package,
    //  since it's not sending the same one
    self.attributionPackageToSend = nil;
    
    return nil;
}

// reason to delay
//  - request should retry
//  - state detected ask_in
- (BOOL)canDelay {
    if (self.isInDelay) {
        [self.logger debug:@"Cannot delay when it's already in delay"];
        return NO;
    }
    
    if (self.isSending) {
        [self.logger debug:@"Cannot delay when it's already sending"];
        return NO;
    }
    
    self.isInDelay = YES;
    
    return YES;
}

- (nullable ADJAttributionPackageData *)attributionPackage {
    if (self.attributionPackageToSend == nil) {
        return nil;
    }
    
    ADJNonEmptyString *_Nullable initiatedByValue =
    [self.attributionPackageToSend.parameters
     pairValueWithKey:ADJParamAttributionInititedByKey];
    
    NSString *_Nullable initiatedBy =
    initiatedByValue != nil ? initiatedByValue.stringValue : nil;
    
    if ([ADJUtilObj objectEquals:initiatedBy other:[self initiatedBy]]) {
        return self.attributionPackageToSend;
    } else {
        return nil;
    }
}

- (nullable NSString *)initiatedBy {
    if (self.askingAttribution == nil) {
        return nil;
    }
    
    if ([self.askingAttribution isEqualToString:ADJAskingAttributionStatusFromBackend]) {
        return ADJParamAttributionInititedByBackendValue;
    }
    if ([self.askingAttribution isEqualToString:ADJAskingAttributionStatusFromSdk]) {
        return ADJParamAttributionInititedBySdkValue;
    }
    if ([self.askingAttribution isEqualToString:ADJAskingAttributionStatusFromBackendAndSdk]) {
        return ADJParamAttributionInititedBySdkAndBackendValue;
    }
    
    return nil;
}

- (void)setAttributionPackageToSendWithData:(nonnull ADJAttributionPackageData *)attributionPackageToSend {
    self.attributionPackageToSend = attributionPackageToSend;
}

#pragma mark Internal Methods
- (BOOL)tryToSend {
    if (self.isInDelay) {
        [self.logger debug:@"Cannot send attribution because it's in delay"];
        return NO;
    }
    
    if (self.isSending) {
        [self.logger debug:@"Cannot send attribution because it's already sending"];
        return NO;
    }
    
    if (self.askingAttribution == nil) {
        [self.logger debug:@"Cannot send attribution because it's not asking"];
        return NO;
    }
    
    if (self.isSdkPaused) {
        [self.logger debug:@"Cannot send attribution because the sdk is paused"];
        return NO;
    }
    
    self.isSending = YES;
    
    return YES;
}

- (nullable ADJDelayData *)delayDataWithRetryIn:(nullable ADJTimeLengthMilli *)retryIn {
    // when retry_in is present, use it without backoff calculations
    if (retryIn != nil) {
        return [[ADJDelayData alloc] initWithDelay:retryIn source:@"retry_in"];
    }
    
    // increase the number of retries for backoff calculation
    self.retriesSinceLastSuccessSend =
    [self.retriesSinceLastSuccessSend generateIncrementedCounter];
    
    ADJTimeLengthMilli *_Nonnull backoffTime =
    [self.backoffStrategy
     calculateBackoffTimeWithRetries:self.retriesSinceLastSuccessSend.countValue];
    
    return [[ADJDelayData alloc] initWithDelay:backoffTime source:@"backoff"];
}

@end

