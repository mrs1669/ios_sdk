//
//  ADJAttributionData.h
//  Adjust
//
//  Created by Aditi Agrawal on 15/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataMapBuilderInjectable.h"
#import "ADJNonEmptyString.h"
#import "ADJMoneyDoubleAmount.h"
#import "ADJAdjustAttribution.h"
#import "ADJOptionalFails.h"
#import "ADJV4Attribution.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAttributionDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJAttributionData : NSObject<ADJIoDataMapBuilderInjectable>
// instantiation
+ (nonnull ADJOptionalFails<ADJAttributionData *> *)
    instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap;

+ (nonnull ADJOptionalFails<ADJAttributionData *> *)
    instanceFromJson:(nonnull NSDictionary *)attributionJson;

- (nonnull instancetype)initWithTrackerToken:(nullable ADJNonEmptyString *)trackerToken
                                 trackerName:(nullable ADJNonEmptyString *)trackerName
                                     network:(nullable ADJNonEmptyString *)network
                                    campaign:(nullable ADJNonEmptyString *)campaign
                                     adgroup:(nullable ADJNonEmptyString *)adgroup
                                    creative:(nullable ADJNonEmptyString *)creative
                                  clickLabel:(nullable ADJNonEmptyString *)clickLabel
                                    deeplink:(nullable ADJNonEmptyString *)deeplink
                                       state:(nullable ADJNonEmptyString *)state
                                    costType:(nullable ADJNonEmptyString *)costType
                                  costAmount:(nullable ADJMoneyDoubleAmount *)costAmount
                                costCurrency:(nullable ADJNonEmptyString *)costCurrency;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerToken;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *network;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *campaign;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adgroup;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *creative;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *clickLabel;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deeplink;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *state;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costType;
@property (nullable, readonly, strong, nonatomic) ADJMoneyDoubleAmount *costAmount;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costCurrency;

// public api
- (nonnull ADJAdjustAttribution *)toAdjustAttribution;

- (nonnull ADJOptionalFails<NSDictionary<NSString *, id> *> *)
    buildInternalCallbackDataWithMethodName:(nonnull NSString *)methodName;

+ (nonnull NSDictionary<NSString *, id> *)toJsonDictionaryWithAdjustAttribution:
    (nonnull ADJAdjustAttribution *)adjustAttribution;

@end
