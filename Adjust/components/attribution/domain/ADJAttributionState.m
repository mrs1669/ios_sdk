//
//  ADJAttributionState.m
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//
#import "ADJAttributionState.h"

#import "ADJAttributionTracker.h"

#pragma mark Fields
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJAttributionStateData *changedStateData;
 @property (nullable, readonly, strong, nonatomic) ADJDelayData *delayData;
 @property (readonly, assign, nonatomic) BOOL startAsking;
 */

@implementation ADJAttributionStateOutputData
#pragma mark Instantiation
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma mark - Private constructors
- (nonnull instancetype)
    initWithChangedStateData:(nullable ADJAttributionStateData *)changedStateData
    delayData:(nullable ADJDelayData *)delayData
    startAsking:(BOOL)startAsking
{
    self = [super init];

    _changedStateData = changedStateData;
    _delayData = delayData;
    _startAsking = startAsking;

    return self;
}

@end

#pragma mark - Public constants
NSString *const ADJAttributionStatusCreated = @"Created";
NSString *const ADJAttributionStatusUpdated = @"Updated";
NSString *const ADJAttributionStatusRead = @"Read";
NSString *const ADJAttributionStatusNotAvailableFromBackend = @"NotAvailableFromBackend";
NSString *const ADJAttributionStatusWaiting = @"Waiting";

@interface ADJAttributionState ()
#pragma mark - Injected dependencies
@property (nonnull, readwrite, strong, nonatomic) ADJAttributionStateData *stateData;
@property (readonly, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL hasSdkStart;

@end

@implementation ADJAttributionState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJAttributionStateData *)initialStateData
              doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
{
    self = [super initWithLoggerFactory:loggerFactory source:@"AttributionState"];
    _stateData = initialStateData;
    _doNotInitiateAttributionFromSdk = doNotInitiateAttributionFromSdk;

    _hasSdkStart = NO;

    return self;
}

#pragma mark Public API
- (nullable ADJAttributionStateOutputData *)receivedAcceptedNonAttributionResponse:
    (nonnull id<ADJSdkResponseData>)nonAttributionResponse
{
    ADJTimeLengthMilli *_Nullable askIn = nonAttributionResponse.askIn;
    if (askIn == nil) { return nil; }

    [self.logger debugDev:@"Ask in found in non attribution response"
                     key1:@"askIn"
                   value1:askIn.description
                     key2:@"sdkResponse"
                   value2:[nonAttributionResponse description]];

    if (self.stateData.isAsking) {
        [self.logger debugDev:
         @"No need to delay to ask for attribution since it is already asking"];

        return nil;
    }

    self.stateData = [self.stateData withNewIsAsking:YES];

    return [[ADJAttributionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            delayData:[[ADJDelayData alloc]
                       initWithDelay:askIn
                       source:@"received accepted non attribution response"]
            startAsking:YES];
}

- (nullable ADJAttributionStateOutputData *)receivedAcceptedAttributionResponse:
    (nonnull ADJAttributionResponseData *)attributionResponse
{
    ADJTimeLengthMilli *_Nullable askIn = attributionResponse.askIn;
    if (askIn != nil) {
        [self.logger debugDev:@"Ask in found in attribution response"
                         key1:@"askIn"
                       value1:askIn.description
                         key2:@"sdkResponse"
                       value2:[attributionResponse description]];

        if (! self.stateData.isAsking) {
            [self.logger debugDev:
             @"It should have been asking when it received an accepted attribution response"
                        issueType:ADJIssueUnexpectedInput];

            return [[ADJAttributionStateOutputData alloc]
                    initWithChangedStateData:self.stateData
                    delayData:
                        [[ADJDelayData alloc]
                         initWithDelay:askIn
                         source:@"unexpected state when received an accepted attribution response"]
                    startAsking:YES];
        }

        return [[ADJAttributionStateOutputData alloc]
                initWithChangedStateData:nil
                delayData:[[ADJDelayData alloc]
                           initWithDelay:askIn
                           source:@"received an accepted attribution response"]
                startAsking:YES];
    }

    [self updateWithReceivedAttribution:[self extractAttributionWithResponse:attributionResponse]];

    self.stateData = [self.stateData withNewIsAsking:NO];

    return [[ADJAttributionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            delayData:nil
            startAsking:NO];
}

- (nullable ADJAttributionStateOutputData *)installSessionTracked {
    if (self.stateData.installSessionTracked) {
        return nil;
    }

    self.stateData = [self.stateData withInstallSessionTracked];

    if ([self canStartAskingFromSdkWithSource:@"installSessionTracked"]) {
        return [self startAskingNow];
    }

    return [[ADJAttributionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            delayData:nil
            startAsking:NO];
}

- (nullable ADJAttributionStateOutputData *)sdkStart {
    self.hasSdkStart = YES;

    if ([self canStartAskingFromSdkWithSource:@"sdkStart"]) {
        return [self startAskingNow];
    }

    return nil;
}

#pragma mark Internal Methods
- (nullable ADJAttributionData *)extractAttributionWithResponse:
    (nonnull ADJAttributionResponseData *)attributionResponseData
{
    NSDictionary *_Nullable attributionJson = attributionResponseData.attributionJson;
    if (attributionJson == nil) { return nil; }

    return [[ADJAttributionData alloc] initFromJsonWithDictionary:attributionJson
                                                             adid:attributionResponseData.adid
                                                           logger:self.logger];
}
- (void)updateWithReceivedAttribution:(nullable ADJAttributionData *)receivedAttribution {
    if (receivedAttribution == nil) {
        if (self.stateData.unavailableAttribution) {
            [self.logger debugDev:@"Received attribution continues to be unavailable"];
            return;
        }

        [self.logger debugDev:@"Received attribution is now unavailable"];

        self.stateData = [self.stateData withUnavailableAttribution];

        return;
    }

    if ([receivedAttribution isEqual:self.stateData.attributionData]) {
        [self.logger debugDev:@"Received same attribution"];
        return;
    }

    [self.logger debugDev:@"Received attribution updates state data"];

    self.stateData = [self.stateData withAvailableAttribution:receivedAttribution];
}

- (BOOL)canStartAskingFromSdkWithSource:(nonnull NSString *)source {
    if (self.doNotInitiateAttributionFromSdk) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"it has been configured to not do so"];
    }

    if (! self.hasSdkStart) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"the sdk has not started yet"];
    }

    if ([self.stateData isAskingStatus]) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"is already asking attribution"];
    }

    if ([self.stateData waitingForInstallSessionTrackingStatus]) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"is waiting for install tracking"];
    }

    if ([self.stateData unavailableAttribution]) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"the attribution is unavailable"];
    }

    if ([self.stateData hasAttributionStatus]) {
        return [self logCannotStartAskingWithSource:source
                                             reason:@"it already has the attribution"];
    }

    if (! [self.stateData canAskStatus]) {
        [self.logger debugDev:@"Unexpected Attribution Status to start asking"
                expectedValue:ADJAttributionStateStatusCanAsk
                  actualValue:[self.stateData attributionStateStatus]
                    issueType:ADJIssueLogicError];
    }

    [self.logger debugDev:@"Can start asking"
                     from:source];

    return YES;
}

- (BOOL)logCannotStartAskingWithSource:(nonnull NSString *)source
                                                        reason:(nonnull NSString *)reason
{
    [self.logger debugDev:@"Cannot start asking"
                     from:source
                      key:@"reason"
                    value:reason];
    return NO;
}

- (nonnull ADJAttributionStateOutputData *)startAskingNow {
    self.stateData = [self.stateData withNewIsAsking:YES];

    return [[ADJAttributionStateOutputData alloc]
            initWithChangedStateData:self.stateData
            delayData:nil
            startAsking:YES];
}

@end
