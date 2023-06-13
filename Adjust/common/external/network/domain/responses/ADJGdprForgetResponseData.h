//
//  ADJGdprForgetResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkResponseBaseData.h"
#import "ADJGdprForgetPackageData.h"

@interface ADJGdprForgetResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFails<ADJGdprForgetResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    gdprForgetPackageData:(nonnull ADJGdprForgetPackageData *)gdprForgetPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJGdprForgetPackageData *sourceGdprForgetPackage;

@end
