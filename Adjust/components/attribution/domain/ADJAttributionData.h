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
#import "ADJOptionalFailsNN.h"
#import "ADJOptionalFailsNL.h"
#import "ADJV4Attribution.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJAttributionDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJAttributionData : NSObject<ADJIoDataMapBuilderInjectable>
// instantiation
+ (nonnull ADJOptionalFailsNN<ADJAttributionData *> *)
    instanceFromIoDataMap:(nonnull ADJStringMap *)ioDataMap;

+ (nonnull ADJOptionalFailsNL<ADJAttributionData *> *)
    instanceFromV4WithAttribution:(nonnull ADJV4Attribution *)v4Attribution;

// TODO: adid to be extracted from attribution
+ (nonnull ADJOptionalFailsNN<ADJAttributionData *> *)
    instanceFromJson:(nonnull NSDictionary *)attributionJson
    adid:(nonnull ADJNonEmptyString *)adid;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerToken;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *trackerName;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *network;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *campaign;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adgroup;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *creative;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *clickLabel;
// TODO: adid to be extracted from attribution
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deeplink;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *state;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costType;
@property (nullable, readonly, strong, nonatomic) ADJMoneyAmountBase *costAmount;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *costCurrency;

// public api
- (nonnull ADJAdjustAttribution *)toAdjustAttribution;

@end
