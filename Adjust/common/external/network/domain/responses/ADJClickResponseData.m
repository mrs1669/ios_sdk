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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJClickResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJClickResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               clickPackageData:clickPackageData
                                           optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:clickPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJClickPackageData *)sourceClickPackageData {
    return (ADJClickPackageData *)self.sourcePackage;
}

@end
