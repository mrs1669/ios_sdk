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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJUnknownResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    unknownPackageData:(nonnull id<ADJSdkPackageData>)unknownPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJUnknownResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               unknownPackageData:unknownPackageData
                                                optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    unknownPackageData:(nonnull id<ADJSdkPackageData>)unknownPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:unknownPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

@end
