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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                       clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
                                 logger:(nonnull ADJLogger *)logger {

    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:clickPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJClickPackageData *)sourceClickPackageData {
    return (ADJClickPackageData *)self.sourcePackage;
}

@end
