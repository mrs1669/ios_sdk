//
//  ADJSessionResponseData.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJSessionPackageData.h"

@interface ADJSessionResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFails<ADJSessionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sessionPackageData:(nonnull ADJSessionPackageData *)sessionPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJSessionPackageData *sourceSessionPackage;

@end
