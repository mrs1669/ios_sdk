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
+ (nonnull ADJOptionalFails<ADJGdprForgetResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJGdprForgetResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               gdprForgetPackageData:gdprForgetPackageData
                                                    optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:gdprForgetPackageData
                 optionalFailsMut:optionalFailsMut];
    
    return self;
}

- (nonnull ADJGdprForgetPackageData *)sourceGdprForgetPackage {
    return (ADJGdprForgetPackageData *)self.sourcePackage;
}

@end
