//
//  ADJThirdPartySharingResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharingResponseData.h"

@implementation ADJThirdPartySharingResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJThirdPartySharingResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    thirdPartySharingPackageData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJThirdPartySharingResponseData alloc]
                   initWithBuilder:sdkResponseDataBuilder
                   thirdPartySharingPackageData:thirdPartySharingPackageData
                   optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    thirdPartySharingPackageData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:thirdPartySharingPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJThirdPartySharingPackageData *)sourceThirdPartySharingPackageData {
    return (ADJThirdPartySharingPackageData *)self.sourcePackage;
}

@end
