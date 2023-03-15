//
//  ADJEventResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJEventResponseData.h"

@implementation ADJEventResponseData
#pragma mark Instantiation
+ (nonnull ADJOptionalFailsNN<ADJEventResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJEventResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               eventPackageData:eventPackageData
                                               optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:eventPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJEventPackageData *)sourceSessionPackage {
    return (ADJEventPackageData *)self.sourcePackage;
}

@end


