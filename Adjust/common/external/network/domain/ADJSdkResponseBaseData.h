//
//  ADJSdkResponseBaseData.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseData.h"
#import "ADJSdkResponseDataBuilder.h"
#import "ADJSdkPackageData.h"
#import "ADJLogger.h"

@interface ADJSdkResponseBaseData : NSObject<ADJSdkResponseData>
// instantiation
- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    logger:(nonnull ADJLogger *)logger
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

@end
