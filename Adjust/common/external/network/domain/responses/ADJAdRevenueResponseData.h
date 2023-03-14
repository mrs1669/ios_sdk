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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJAdRevenueResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJAdRevenuePackageData *sourceAdRevenuePackageData;

@end
