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
+ (nonnull ADJOptionalFails<ADJMeasurementConsentResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    measurementConsentPackageData:
        (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData
{
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    return [[ADJOptionalFails alloc]
            initWithOptionalFails:optionalFailsMut
            value:[[ADJMeasurementConsentResponseData alloc]
                   initWithBuilder:sdkResponseDataBuilder
                   measurementConsentPackageData:measurementConsentPackageData
                   optionalFailsMut:optionalFailsMut]];
}

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    measurementConsentPackageData:
        (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
{
    self = [super initWithBuilder:sdkResponseDataBuilder
                   sdkPackageData:measurementConsentPackageData
                 optionalFailsMut:optionalFailsMut];

    return self;
}

- (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData {
    return (ADJMeasurementConsentPackageData *)self.sourcePackage;
}

@end
