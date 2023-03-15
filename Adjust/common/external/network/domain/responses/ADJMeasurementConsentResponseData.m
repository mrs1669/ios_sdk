//
//  ADJMeasurementConsentResponseData.m
//  Adjust
//
//  Created by Genady Buchatsky on 15.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementConsentResponseData.h"

@implementation ADJMeasurementConsentResponseData
#pragma mark Instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
          measurementConsentPackageData:(nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData
                                 logger:(nonnull ADJLogger *)logger {
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:measurementConsentPackageData
                           logger:logger];
    return self;
}

- (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData {
    return (ADJMeasurementConsentPackageData *)self.sourcePackage;
}
@end
