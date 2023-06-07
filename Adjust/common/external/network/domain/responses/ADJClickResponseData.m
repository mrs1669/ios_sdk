//
//  ADJClickResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClickResponseData.h"

@implementation ADJClickResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJClickResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJClickResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               clickPackageData:clickPackageData
                                               optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:clickPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJClickPackageData *)sourceClickPackageData {
    return (ADJClickPackageData *)self.sourcePackage;
}

@end
