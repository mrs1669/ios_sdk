//
//  ADJGdprForgetStateData.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJIoData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJGdprForgetStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJGdprForgetStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJIoData *)ioData
                                     logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initAskedButNotForgotten;

- (nonnull instancetype)initForgottenByBackendWithAskedToForgetBySdk:(BOOL)askedToForgetBySdk;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL forgottenByBackend;
@property (readonly, assign, nonatomic) BOOL askedToForgetBySdk;

// public api
- (BOOL)isForgotten;

@end
