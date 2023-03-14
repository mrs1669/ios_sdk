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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJAttributionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJAttributionResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               attributionPackageData:attributionPackageData
                                                 optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:attributionPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJAttributionPackageData *)sourceAttributionPackageData {
    return (ADJAttributionPackageData *)self.sourcePackage;
}

@end
