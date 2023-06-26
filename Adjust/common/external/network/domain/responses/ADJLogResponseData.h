//
//  ADJLogResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJLogPackageData.h"

@interface ADJLogResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFails<ADJLogResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    logPackageData:(nonnull ADJLogPackageData *)logPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJLogPackageData *sourceLogPackageData;

@end
