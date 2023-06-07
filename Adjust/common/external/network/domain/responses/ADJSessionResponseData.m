//
//  ADJSessionResponseData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSessionResponseData.h"

@implementation ADJSessionResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJSessionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sessionPackageData:(nonnull ADJSessionPackageData *)sessionPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJSessionResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               sessionPackageData:sessionPackageData
                                                 optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sessionPackageData:(nonnull ADJSessionPackageData *)sessionPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:sessionPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJSessionPackageData *)sourceSessionPackage {
    return (ADJSessionPackageData *)self.sourcePackage;
}

@end
