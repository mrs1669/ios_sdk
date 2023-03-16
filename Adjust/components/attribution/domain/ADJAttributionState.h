//
//  ADJAttributionState.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJAttributionResponseData.h"
#import "ADJAttributionStateData.h"
#import "ADJValueWO.h"
#import "ADJSessionResponseData.h"
#import "ADJSdkResponseData.h"
#import "ADJDelayData.h"

@interface ADJAttributionStateOutputData : NSObject

@property (nullable, readonly, strong, nonatomic) ADJAttributionStateData *changedStateData;
@property (nullable, readonly, strong, nonatomic) ADJDelayData *delayData;
@property (readonly, assign, nonatomic) BOOL startAsking;

- (nullable instancetype)init NS_UNAVAILABLE;

@end

@interface ADJAttributionState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJAttributionStateData *)initialStateData
              doNotInitiateAttributionFromSdk:(BOOL)doNotInitiateAttributionFromSdk;

// public api
- (nullable ADJAttributionStateOutputData *)receivedAcceptedNonAttributionResponse:
    (nonnull id<ADJSdkResponseData>)nonAttributionResponse;

- (nullable ADJAttributionStateOutputData *)receivedAcceptedAttributionResponse:
    (nonnull ADJAttributionResponseData *)attributionResponse;

- (nullable ADJAttributionStateOutputData *)installSessionTracked;

- (nullable ADJAttributionStateOutputData *)sdkStart;

@end
