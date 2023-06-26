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
#import "ADJV4UserDefaultsData.h"
#import "ADJV4ActivityState.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJGdprForgetStateDataMetadataTypeValue;

typedef NSString *ADJGdprForgetStatus NS_TYPED_ENUM;
FOUNDATION_EXPORT ADJGdprForgetStatus const ADJGdprForgetStatusAskedToForget;
FOUNDATION_EXPORT ADJGdprForgetStatus const ADJGdprForgetStatusForgottenByBackend;

NS_ASSUME_NONNULL_END

@interface ADJGdprForgetStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJResult<ADJGdprForgetStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData;

+ (nullable ADJGdprForgetStateData *)instanceFromV4WithUserDefaults:
    (nonnull ADJV4UserDefaultsData *)v4UserDefaultsData;
+ (nullable ADJGdprForgetStateData *)instanceFromV4WithActivityState:
    (nonnull ADJV4ActivityState *)v4ActivityState;

- (nonnull instancetype)initWithInitialState;

- (nonnull instancetype)initAskedButNotForgotten;

- (nonnull instancetype)initForgottenByBackendWithAskedToForgetBySdk:(BOOL)askedToForgetBySdk;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (readonly, assign, nonatomic) BOOL forgottenByBackend;
@property (readonly, assign, nonatomic) BOOL askedToForgetBySdk;

// public api
- (BOOL)isForgotten;
- (BOOL)isAsking;
- (nullable ADJGdprForgetStatus)status;

@end
