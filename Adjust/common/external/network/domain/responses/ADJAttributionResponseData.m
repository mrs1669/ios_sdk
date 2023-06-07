//
//  ADJAttributionResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionResponseData.h"

@implementation ADJAttributionResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJAttributionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJAttributionResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               attributionPackageData:attributionPackageData
                                                     optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:attributionPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJAttributionPackageData *)sourceAttributionPackageData {
    return (ADJAttributionPackageData *)self.sourcePackage;
}

@end
