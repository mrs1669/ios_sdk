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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
           thirdPartySharingPackageData: (nonnull ADJThirdPartySharingPackageData *)thirdPartySharingPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:thirdPartySharingPackageData
                           logger:logger];

    return self;
}

- (nonnull ADJThirdPartySharingPackageData *)sourceThirdPartySharingPackageData {
    return (ADJThirdPartySharingPackageData *)self.sourcePackage;
}

@end
