//
//  ADJEventResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 16/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJEventPackageData.h"

@interface ADJEventResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFailsNN<ADJEventResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    eventPackageData:(nonnull ADJEventPackageData *)eventPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJEventPackageData *sourceEventPackage;

@end

