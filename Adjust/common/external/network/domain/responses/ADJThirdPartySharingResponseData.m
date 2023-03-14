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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJThirdPartySharingResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    thirdPartySharingPackageData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJThirdPartySharingResponseData alloc]
                   initWithBuilder:sdkResponseDataBuilder
                   thirdPartySharingPackageData:thirdPartySharingPackageData
                   optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    thirdPartySharingPackageData:
        (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:thirdPartySharingPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJThirdPartySharingPackageData *)sourceThirdPartySharingPackageData {
    return (ADJThirdPartySharingPackageData *)self.sourcePackage;
}

@end
