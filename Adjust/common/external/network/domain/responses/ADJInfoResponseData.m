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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                        infoPackageData:(nonnull ADJInfoPackageData *)infoPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:infoPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJInfoPackageData *)infoPackageData {
    return (ADJInfoPackageData *)self.sourcePackage;
}

@end
