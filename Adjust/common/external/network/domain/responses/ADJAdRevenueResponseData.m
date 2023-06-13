//
//  ADJAdRevenueResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdRevenueResponseData.h"

@implementation ADJAdRevenueResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFails<ADJAdRevenueResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJAdRevenueResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               adRevenuePackageData:adRevenuePackageData
                                                   optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:adRevenuePackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJAdRevenuePackageData *)sourceAdRevenuePackageData {
    return (ADJAdRevenuePackageData *)self.sourcePackage;
}

@end
