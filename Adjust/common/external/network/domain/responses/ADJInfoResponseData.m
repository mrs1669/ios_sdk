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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJInfoResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJInfoResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               infoPackageData:infoPackageData
                                          optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:infoPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJInfoPackageData *)infoPackageData {
    return (ADJInfoPackageData *)self.sourcePackage;
}

@end
