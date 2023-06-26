//
//  ADJInfoResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 30/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJInfoResponseData.h"

@implementation ADJInfoResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFails<ADJInfoResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMUt = [[NSMutableArray alloc] init];
    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMUt
            value:[[ADJInfoResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               infoPackageData:infoPackageData
                                              optionalFailsMut:optionalFailsMUt]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:infoPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJInfoPackageData *)infoPackageData {
    return (ADJInfoPackageData *)self.sourcePackage;
}

@end
