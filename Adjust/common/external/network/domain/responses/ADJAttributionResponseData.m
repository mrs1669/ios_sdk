//
//  ADJAttributionResponseData.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionResponseData.h"

@implementation ADJAttributionResponseData
#pragma mark Instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                 attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:attributionPackageData
                           logger:logger];
    
    return self;
}

- (nonnull ADJAttributionPackageData *)sourceAttributionPackageData {
    return (ADJAttributionPackageData *)self.sourcePackage;
}

@end
