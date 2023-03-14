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
+ (nonnull ADJCollectionAndValue<ADJResultFail *, ADJEventResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsBuilder = [[NSMutableArray alloc] init];
    return [[ADJCollectionAndValue alloc]
            initWithCollection:optionalFailsBuilder
            value:[[ADJEventResponseData alloc] initWithBuilder:sdkResponseDataBuilder
                                               eventPackageData:eventPackageData
                                           optionalFailsBuilder:optionalFailsBuilder]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
    optionalFailsBuilder:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsBuilder
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:eventPackageData
             optionalFailsBuilder:optionalFailsBuilder];

    return self;
}

- (nonnull ADJEventPackageData *)sourceSessionPackage {
    return (ADJEventPackageData *)self.sourcePackage;
}

@end


