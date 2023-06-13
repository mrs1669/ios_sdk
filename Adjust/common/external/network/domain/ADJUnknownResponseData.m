//
//  ADJUnknownResponseData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJUnknownResponseData.h"

@implementation ADJUnknownResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFails<ADJUnknownResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    unknownPackageData:(nonnull id<ADJSdkPackageData>)unknownPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJUnknownResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               unknownPackageData:unknownPackageData
                                                 optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    unknownPackageData:(nonnull id<ADJSdkPackageData>)unknownPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:unknownPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

@end
