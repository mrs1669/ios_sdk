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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                       eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:eventPackageData
                           logger:logger];
    
    return self;
}

- (nonnull ADJEventPackageData *)sourceSessionPackage {
    return (ADJEventPackageData *)self.sourcePackage;
}

@end


