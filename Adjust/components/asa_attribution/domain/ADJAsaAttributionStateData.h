//
//  ADJAsaAttributionStateData.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataSerializable.h"
#import "ADJNonEmptyString.h"
#import "ADJTimestampMilli.h"
#import "ADJOptionalFailsNN.h"
#import "ADJV4UserDefaultsData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAsaAttributionStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJAsaAttributionStateData : NSObject<ADJIoDataSerializable>
// instantiation
+ (nonnull ADJOptionalFailsNN<ADJResultNN<ADJAsaAttributionStateData *> *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData;

+ (nullable ADJAsaAttributionStateData *)instanceFromV4WithUserDefaults:
    (nonnull ADJV4UserDefaultsData *)v4UserDefaultsData;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithHasReceivedValidAsaClickResponse:(BOOL)hasReceivedValidAsaClickResponse
                                    hasReceivedAdjustAttribution:(BOOL)hasReceivedAdjustAttribution
                                                     cachedToken:(nullable ADJNonEmptyString *)cachedToken
                                              cacheReadTimestamp:(nullable ADJTimestampMilli *)cacheReadTimestamp
                                                     errorReason:(nullable ADJNonEmptyString *)errorReason
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public api
- (nonnull ADJAsaAttributionStateData *)withHasReceivedValidAsaClickResponse;
- (nonnull ADJAsaAttributionStateData *)withHasReceivedAdjustAttribution;
- (nonnull ADJAsaAttributionStateData *)withToken:(nullable ADJNonEmptyString *)token
                                        timestamp:(nullable ADJTimestampMilli *)timestamp
                                      errorReason:(nullable ADJNonEmptyString *)errorReason;

// public properties
@property (readonly, assign, nonatomic) BOOL hasReceivedValidAsaClickResponse;
@property (readonly, assign, nonatomic) BOOL hasReceivedAdjustAttribution;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cachedToken;
@property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *cacheReadTimestamp;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *errorReason;

@end
