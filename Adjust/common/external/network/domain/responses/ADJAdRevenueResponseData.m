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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJAdRevenueResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJAdRevenueResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               adRevenuePackageData:adRevenuePackageData
                                               optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:adRevenuePackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJAdRevenuePackageData *)sourceAdRevenuePackageData {
    return (ADJAdRevenuePackageData *)self.sourcePackage;
}

@end
