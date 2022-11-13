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
#pragma mark - Public constants
NSString *const ADJAttributionStatusCreated = @"Created";
NSString *const ADJAttributionStatusUpdated = @"Updated";
NSString *const ADJAttributionStatusRead = @"Read";
NSString *const ADJAttributionStatusNotAvailableFromBackend = @"NotAvailableFromBackend";
NSString *const ADJAttributionStatusWaiting = @"Waiting";

@interface ADJAttributionState ()
#pragma mark - Injected dependencies
@property (readonly, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) BOOL isFirstSessionWaitingToBeSent;
@property (readwrite, assign, nonatomic) BOOL wasSessionSent;
@property (readwrite, assign, nonatomic) BOOL isFirstStart;
@property (readwrite, assign, nonatomic) BOOL hasSdkStart;

@end

@implementation ADJAttributionState
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
              doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk
                        isFirstSessionInQueue:(BOOL)isFirstSessionInQueue
{
    self = [super initWithLoggerFactory:loggerFactory source:@"AttributionState"];
    _doNotInitiateAttributionFromSdk = doNotInitiateAttributionFromSdk;

    _isFirstSessionWaitingToBeSent = isFirstSessionInQueue;

    _wasSessionSent = NO;

    _isFirstStart = YES;

    _hasSdkStart = NO;

    return self;
}

#pragma mark Public API
- (BOOL)
    stopAskingWhenReceivedAcceptedAttributionResponseWithCurrentAttributionStateData:
        (nonnull ADJAttributionStateData *)currentAttributionStateData
    attributionResponseData:(nonnull ADJAttributionResponseData *)attributionResponseData
    changedAttributionStateDataWO:
        (nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
    attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO
{
    if (attributionResponseData.shouldRetry) {
        [self.logger debugDev:
            @"Cannot process attribution data when received non accepted attribution response"
                    issueType:ADJIssueLogicError];
        return NO;
    }

    // attribution data is ignored with ask_in
    if (attributionResponseData.askIn != nil) {
        return NO;
    }

    ADJAttributionData *_Nullable attributionDataFromResponse =
        [self extractAttributionWithResponse:attributionResponseData];

    if (attributionDataFromResponse == nil) {
        [self.logger debugDev:@"Process unavailable attribution"
            " because it could not extract attribution from response"];

        [self
         processUnavailableAttributionWithCurrentAttributionStateData:
             currentAttributionStateData
         changedAttributionStateDataWO:changedAttributionStateDataWO
         attributionStatusEventWO:attributionStatusEventWO];
    } else {
        [self.logger debugDev:@"Process received attribution"
         " because it could extract attribution from response"];

        [self
         processReceivedAttributionCurrentAttributionStateData:currentAttributionStateData
         attributionDataFromResponse:attributionDataFromResponse
         changedAttributionStateDataWO:changedAttributionStateDataWO
         attributionStatusEventWO:attributionStatusEventWO];
    }

    return YES;
}

- (nullable NSString *)
    startAskingWhenReceivedProcessedSessionResponseWithCurrentAttributionStateData:
        (nonnull ADJAttributionStateData *)currentAttributionStateData
    sessionResponseData:(nonnull ADJSessionResponseData *)sessionResponseData
    changedAttributionStateDataWO:
        (nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
    attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO
{
    [self updateSessionSendingStatusWithSessionResponse:sessionResponseData];

    [self
     updateReceivedSessionResponseWithCurrentAttributionStateData:currentAttributionStateData
     changedAttributionStateDataWO:changedAttributionStateDataWO];

    ADJAttributionStateData *_Nullable changedAttributionStateData =
    [changedAttributionStateDataWO changedValue];

    if (changedAttributionStateData == nil) {
        return nil;
    }

    if ([changedAttributionStateData unavailableStatus]) {
        [attributionStatusEventWO setNewValue:ADJAttributionStatusNotAvailableFromBackend];
        return nil;
    }

    return [self
            startAskingFromSdkWithLatestAttributionStateData:changedAttributionStateData
            changedAttributionStateDataWO:changedAttributionStateDataWO
            sourceDescription:@"ReceivedProcessedSessionResponse"];
}

// 1. With ask_in
//  ASKING_FROM_SDK ? -> ASKING_FROM_BACKEND_AND_SDK
//  !ASKING_FROM_BACKEND && !ASKING_FROM_BACKEND_AND_SDK -> ASKING_FROM_BACKEND
// 2. Without ask_in
//  * ->
- (nullable NSString *)
    startAskingWhenReceivedAcceptedSdkResponseWithCurrentAttributionStateData:
        (nonnull ADJAttributionStateData *)currentAttributionStateData
    sdkResponse:(nonnull id<ADJSdkResponseData>)sdkResponse
    changedAttributionStateDataWO:
        (nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
    delayDataWO:(nonnull ADJValueWO<ADJDelayData *> *)delayDataWO
{
    ADJTimeLengthMilli *_Nullable askIn = sdkResponse.askIn;
    if (askIn == nil) {
        return nil;
    }

    [self.logger debugDev:@"Ask in found in response"
                     key:@"askIn"
                    value:askIn.description];

    NSString *_Nonnull askingAttributionFromBackend =
        [self startAskingFromBackendWithCurrentAttributionStateData:currentAttributionStateData
                                      changedAttributionStateDataWO:changedAttributionStateDataWO];

    [delayDataWO setNewValue:[[ADJDelayData alloc] initWithDelay:askIn source:@"askIn"]];

    return askingAttributionFromBackend;
}

- (nonnull NSString *)statusEventAtGateOpenWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData {
    if ([currentAttributionStateData unavailableStatus]) {
        return ADJAttributionStatusNotAvailableFromBackend;
    }

    if (currentAttributionStateData.attributionData != nil) {
        return ADJAttributionStatusRead;
    } else {
        return ADJAttributionStatusWaiting;
    }
}

- (nullable NSString *)startAskingWhenSdkStartWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                                                 isFirstStart:(BOOL)isFirstStart
                                                changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO {
    self.hasSdkStart = YES;

    self.isFirstStart = isFirstStart;

    [self
     updateReceivedSessionResponseWithCurrentAttributionStateData:currentAttributionStateData
     changedAttributionStateDataWO:changedAttributionStateDataWO];

    ADJAttributionStateData *_Nullable changedAttributionStateData =
    [changedAttributionStateDataWO changedValue];

    ADJAttributionStateData *_Nonnull latestAttributionStateData =
    changedAttributionStateData != nil ?
    changedAttributionStateData : currentAttributionStateData;

    return [self startAskingFromSdkWithLatestAttributionStateData:latestAttributionStateData
                                    changedAttributionStateDataWO:changedAttributionStateDataWO
                                                sourceDescription:@"SdkStart"];
}

#pragma mark Internal Methods
- (nullable ADJAttributionData *)extractAttributionWithResponse:(nonnull ADJAttributionResponseData *)attributionResponseData {
    NSDictionary *_Nullable attributionJson = attributionResponseData.attributionJson;
    if (attributionJson == nil) {
        return nil;
    }

    return [[ADJAttributionData alloc] initFromJsonWithDictionary:attributionJson
                                                             adid:attributionResponseData.adid
                                                           logger:self.logger];
}

- (void)
    processUnavailableAttributionWithCurrentAttributionStateData:
        (nonnull ADJAttributionStateData *)currentAttributionStateData
    changedAttributionStateDataWO:
        (nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
    attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO
{
    ADJAttributionStateData *_Nonnull receivedUnavailableAttributionStateData =
        [[ADJAttributionStateData alloc]
         // Clears attribution
         initWithAttributionData:nil
         receivedSessionResponse:currentAttributionStateData.receivedSessionResponse
         // Sets unavailableAttribution to true
         //  to mark that is has not received a valid attribution from the backend
         unavailableAttribution:YES
         // Clears asking askingFromSdk askingFromBackend to false
         //  to mark that it has received an attribution response
         askingFromSdk:NO
         askingFromBackend:NO];

    // nothing to do when is already not available
    if ([receivedUnavailableAttributionStateData isEqual:currentAttributionStateData]) {
        return;
    }

    [changedAttributionStateDataWO setNewValue:receivedUnavailableAttributionStateData];

    if ([receivedUnavailableAttributionStateData unavailableStatus]) {
        [attributionStatusEventWO setNewValue:ADJAttributionStatusNotAvailableFromBackend];
    } else {
        [self.logger debugDev:
            @"Cannot trigger expected NotAvailableFromBackend without being unavailableFromBackend"
                    issueType:ADJIssueLogicError];
    }
}

- (void)processReceivedAttributionCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                  attributionDataFromResponse:(nullable ADJAttributionData *)attributionDataFromResponse
                                changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
                                     attributionStatusEventWO:(nonnull ADJValueWO<NSString *> *)attributionStatusEventWO {
    ADJAttributionStateData *_Nonnull receivedAttributionStateData =
    [[ADJAttributionStateData alloc]
     // Saves received attribution
     initWithAttributionData:attributionDataFromResponse
     receivedSessionResponse:currentAttributionStateData.receivedSessionResponse
     // Clears unavailableAttribution to false
     //  to mark that is has received a valid attribution from the backend
     unavailableAttribution:NO
     // Clears asking askingFromSdk askingFromBackend to false
     //  to mark that it has received an attribution response
     askingFromSdk:NO
     askingFromBackend:NO];

    // nothing to do when the received attribution is the same as the current one
    if ([receivedAttributionStateData isEqual:currentAttributionStateData]) {
        return;
    }

    // only publish attribution status event if it's considered a new attribution
    if (! [attributionDataFromResponse isEqual:currentAttributionStateData.attributionData]) {
        if (currentAttributionStateData.attributionData != nil) {
            [attributionStatusEventWO setNewValue:ADJAttributionStatusUpdated];
        } else {
            [attributionStatusEventWO setNewValue:ADJAttributionStatusCreated];
        }
    } else {
        [self.logger debugDev:
            @"Not setting AttributionStatusEvent when attributionData is the same"];
    }

    [changedAttributionStateDataWO setNewValue:receivedAttributionStateData];
}

- (void)updateSessionSendingStatusWithSessionResponse:(nonnull ADJSessionResponseData *)sessionResponseData {
    self.wasSessionSent = YES;

    BOOL wasFirstSessionSent = [sessionResponseData.sourceSessionPackage isFirstSession];

    if (wasFirstSessionSent) {
        self.isFirstSessionWaitingToBeSent = NO;
    }
}

- (void)updateReceivedSessionResponseWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                       changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO {
    if (! [self needsToUpdateReceivedSessionResponseWithCurrentAttributionStateData:
           currentAttributionStateData]) {
        return;
    }

    [changedAttributionStateDataWO setNewValue:
     [[ADJAttributionStateData alloc]
      initWithAttributionData:currentAttributionStateData.attributionData
      // Set only receivedSessionResponse to true
      receivedSessionResponse:YES
      unavailableAttribution:currentAttributionStateData.unavailableAttribution
      askingFromSdk:currentAttributionStateData.askingFromSdk
      askingFromBackend:currentAttributionStateData.askingFromBackend]];
}

- (BOOL)needsToUpdateReceivedSessionResponseWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData {
    if (currentAttributionStateData.receivedSessionResponse) {
        return NO;
    }

    if (self.wasSessionSent) {
        return YES;
    }

    if (! self.hasSdkStart) {
        return NO;
    }

    // when it's not first start
    //  - if it still has the first session package in the main queue
    //      -> has not received session response
    //  - if we can't find the first session package in the main queue
    //      -> assume that it has received session response at some point
    //      since there are no feasible scenarios where all are true:
    //      1. The sdk has started before (not first start)
    //      2. The first session package is *not* in the package queue
    //      3. The session has not been processed in the backend
    if (! self.isFirstStart) {
        return ! self.isFirstSessionWaitingToBeSent;
    }

    // when it's first start
    //  assume wasSessionSent will catch it
    return NO;
}

- (nonnull NSString *)startAskingFromBackendWithCurrentAttributionStateData:(nonnull ADJAttributionStateData *)currentAttributionStateData
                                              changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO {
    if (! currentAttributionStateData.askingFromBackend) {
        [changedAttributionStateDataWO setNewValue:
         [[ADJAttributionStateData alloc]
          initWithAttributionData:currentAttributionStateData.attributionData
          receivedSessionResponse:currentAttributionStateData.receivedSessionResponse
          unavailableAttribution:currentAttributionStateData.unavailableAttribution
          askingFromSdk:currentAttributionStateData.askingFromSdk
          // Set only askingFromBackend to true
          askingFromBackend:YES]];
    } else {
        [self.logger debugDev:@"Cannot start asking from backend, since it's already doing it"];
    }

    if (currentAttributionStateData.askingFromSdk) {
        return ADJAskingAttributionStatusFromBackendAndSdk;
    } else {
        return ADJAskingAttributionStatusFromBackend;
    }
}

- (nullable NSString *)startAskingFromSdkWithLatestAttributionStateData:(nonnull ADJAttributionStateData *)latestAttributionStateData
                                          changedAttributionStateDataWO:(nonnull ADJValueWO<ADJAttributionStateData *> *)changedAttributionStateDataWO
                                                      sourceDescription:(nonnull NSString *)sourceDescription {
    if (self.doNotInitiateAttributionFromSdk) {
        return [self logCannotStartAskingWithSource:sourceDescription
                                             reason:@"it has been configured to not do so"];
    }

    if (! self.hasSdkStart) {
        return [self logCannotStartAskingWithSource:sourceDescription
                                             reason:@"the sdk has not started yet"];
    }

    if ([latestAttributionStateData waitingForSessionResponseStatus]) {
        return [self logCannotStartAskingWithSource:sourceDescription
                                             reason:@"is waiting for session response"];
    }

    if ([latestAttributionStateData unavailableStatus]) {
        return [self
                logCannotStartAskingWithSource:sourceDescription
                reason:@"the attribution was unavailable from the backend"];
    }

    if ([latestAttributionStateData hasAttributionStatus]) {
        return [self logCannotStartAskingWithSource:sourceDescription
                                             reason:@"it already has the attribution"];
    }

    if ([latestAttributionStateData askingFromBackendAndSdkStatus]) {
        [self logStartAskingWihtSource:sourceDescription startingSource:@"backend and sdk"];

        return ADJAskingAttributionStatusFromBackendAndSdk;
    }

    if ([latestAttributionStateData askingFromSdk]) {
        [self logStartAskingWihtSource:sourceDescription startingSource:@"sdk"];

        return ADJAskingAttributionStatusFromSdk;
    }

    [changedAttributionStateDataWO setNewValue:
     [[ADJAttributionStateData alloc]
      initWithAttributionData:latestAttributionStateData.attributionData
      receivedSessionResponse:latestAttributionStateData.receivedSessionResponse
      unavailableAttribution:latestAttributionStateData.unavailableAttribution
      // Set only askingFromSdk to true
      askingFromSdk:YES
      askingFromBackend:latestAttributionStateData.askingFromBackend]];

    if (latestAttributionStateData.askingFromBackend) {
        [self logStartAskingWihtSource:sourceDescription startingSource:@"backend and sdk"];

        return ADJAskingAttributionStatusFromBackendAndSdk;
    } else {
        [self logStartAskingWihtSource:sourceDescription startingSource:@"sdk"];

        return ADJAskingAttributionStatusFromSdk;
    }

    return nil;
}

- (nullable NSString *)logCannotStartAskingWithSource:(nonnull NSString *)source
                                               reason:(nonnull NSString *)reason
{
    [self.logger debugDevStart:@"Cannot start asking"]
        .wKv(@"from", source)
        .wKv(@"reason", reason)
        .end();
    return nil;
}

- (void)logStartAskingWihtSource:(nonnull NSString *)source
                  startingSource:(nonnull NSString *)startingSource
{
    [self.logger debugDevStart:@"Start asking"]
        .wKv(@"from", source)
        .wKv(@"starting_source", startingSource)
        .end();
}

@end

