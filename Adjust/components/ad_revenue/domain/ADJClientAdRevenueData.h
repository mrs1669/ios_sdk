//
//  ADJClientAdRevenueData.h
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustAdRevenue.h"
#import "ADJIoData.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJMoney.h"
#import "ADJNonNegativeInt.h"
#import "ADJStringMap.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientAdRevenueDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientAdRevenueData : NSObject<ADJClientActionIoDataInjectable>
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustAdRevenue:(nullable ADJAdjustAdRevenue *)adjustAdRevenue
                                                        logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *source;
@property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *adImpressionsCount;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenueNetwork;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenueUnit;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adRevenuePlacement;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;

@end
