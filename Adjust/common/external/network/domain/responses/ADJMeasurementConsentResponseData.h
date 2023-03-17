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
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
          measurementConsentPackageData:(nonnull ADJMeasurementConsentPackageData *)measurementConsentPackageData
                                 logger:(nonnull ADJLogger *)logger;
@end

