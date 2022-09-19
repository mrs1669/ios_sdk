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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                  gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:gdprForgetPackageData
                           logger:logger];
    
    return self;
}

- (nonnull ADJGdprForgetPackageData *)sourceGdprForgetPackage {
    return (ADJGdprForgetPackageData *)self.sourcePackage;
}

@end
