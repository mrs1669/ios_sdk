//
//  ADJSessionResponseData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSessionResponseData.h"

@implementation ADJSessionResponseData
#pragma mark Instantiation
- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sessionPackageData:(nonnull ADJSessionPackageData *)sessionPackageData
    logger:(nonnull ADJLogger *)logger
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:sessionPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJSessionPackageData *)sourceSessionPackage {
    return (ADJSessionPackageData *)self.sourcePackage;
}

@end
