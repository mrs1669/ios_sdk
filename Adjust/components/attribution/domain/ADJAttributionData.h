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
#import "ADJMoneyAmountBase.h"
#import "ADJAdjustAttribution.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAttributionDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJAttributionData : NSObject<ADJIoDataMapBuilderInjectable>
// instantiation
+ (nullable instancetype)instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap
                                        logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initFromExternalDataWithLogger:(nonnull ADJLogger *)logger
                                    trackerTokenString:(nullable NSString *)trackerTokenString
                                     trackerNameString:(nullable NSString *)trackerNameString
                                         networkString:(nullable NSString *)networkString
                                        campaignString:(nullable NSString *)campaignString
                                         adgroupString:(nullable NSString *)adgroupString
                                        creativeString:(nullable NSString *)creativeString
                                      clickLabelString:(nullable NSString *)clickLabelString
                                            adidString:(nullable NSString *)adidString
                                        costTypeString:(nullable NSString *)costTypeString
                                costAmountDoubleNumber:(nullable NSNumber *)costAmountDoubleNumber
                                    costCurrencyString:(nullable NSString *)costCurrencyString;

- (nonnull instancetype)initFromJsonWithDictionary:(nonnull NSDictionary *)jsonDictionary
                                              adid:(nonnull ADJNonEmptyString *)adid
                                            logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerToken;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *network;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *campaign;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adgroup;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *creative;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *clickLabel;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deeplink;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *state;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costType;
@property (nullable, readonly, strong, nonatomic) ADJMoneyAmountBase *costAmount;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costCurrency;

// public api
- (nonnull ADJAdjustAttribution *)toAdjustAttribution;

@end
