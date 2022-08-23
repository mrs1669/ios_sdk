//
//  ADJAdRevenueResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJAdRevenuePackageData.h"

@interface ADJAdRevenueResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                   adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenuePackageData *sourceAdRevenuePackageData;

@end
