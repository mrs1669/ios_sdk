//
//  ADJMeasurementConsentPackageData.m
//  Adjust
//
//  Created by Genady Buchatsky on 15.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMeasurementConsentPackageData.h"
#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJMeasurementConsentPackageDataPath = @"measurement_consent";

@implementation ADJMeasurementConsentPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJMeasurementConsentPackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:YES
                    parameters:parameters];
    return self;
}

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
                                   logger:(nonnull ADJLogger *)logger {
    // does not read ioData for further information
    return [self initWithClientSdk:clientSdk parameters:parameters];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable measurementConsent =
        [self.parameters pairValueWithKey:ADJParamMeasurementConsentKey];

    if (measurementConsent == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:@"Measurement consent without value"];
    }

    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"Measurement consent with value: %@", measurementConsent]];
}
@end
