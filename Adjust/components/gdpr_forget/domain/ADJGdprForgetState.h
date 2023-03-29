//
//  ADJGdprForgetState.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJGdprForgetStateData.h"
#import "ADJDelayData.h"

@interface ADJGdprForgetStateOutputData : NSObject

@property (nullable, readonly, strong, nonatomic) ADJGdprForgetStateData *changedStateData;
@property (nullable, readonly, strong, nonatomic) ADJGdprForgetStatus status;
@property (readonly, assign, nonatomic) BOOL startTracking;

- (nullable instancetype)init NS_UNAVAILABLE;

@end

@interface ADJGdprForgetState : ADJCommonBase
// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJGdprForgetStateData *)initialStateData;

// public api
- (nullable ADJGdprForgetStateOutputData *)forgottenByClient;

- (nullable ADJGdprForgetStateOutputData *)appStart;

- (nullable ADJGdprForgetStateOutputData *)receivedOptOut;

- (nullable ADJGdprForgetStateOutputData *)receivedAcceptedGdprResponse;

@end
