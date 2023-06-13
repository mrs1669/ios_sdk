//
//  ADJMeasurementConsentResponseData.h
//  Adjust
//
//  Created by Genady Buchatsky on 15.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJSdkResponseBaseData.h"
#import "ADJMeasurementConsentPackageData.h"

@interface ADJMeasurementConsentResponseData : ADJSdkResponseBaseData
// public properties
@property (nonnull, readonly, strong, nonatomic) ADJMeasurementConsentPackageData *measurementConsentPackageData;

// instantiation
+ (nonnull ADJOptionalFails<ADJMeasurementConsentResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    measurementConsentPackageData:
        (nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

@end
