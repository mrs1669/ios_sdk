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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                   adRevenuePackageData:(nonnull ADJAdRevenuePackageData *)adRevenuePackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:adRevenuePackageData
                           logger:logger];

    return self;
}

- (nonnull ADJAdRevenuePackageData *)sourceAdRevenuePackageData {
    return (ADJAdRevenuePackageData *)self.sourcePackage;
}

@end
