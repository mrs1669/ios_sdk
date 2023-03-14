//
//  ADJGdprForgetResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJGdprForgetResponseData.h"

@implementation ADJGdprForgetResponseData
#pragma mark Instantiation
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJGdprForgetResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJGdprForgetResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               gdprForgetPackageData:gdprForgetPackageData
                                                optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:gdprForgetPackageData
             optionalFailsBuilder:optionalFailsBuilder];
    
    return self;
}

- (nonnull ADJGdprForgetPackageData *)sourceGdprForgetPackage {
    return (ADJGdprForgetPackageData *)self.sourcePackage;
}

@end
