//
//  ADJAttributionResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 16/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJAttributionPackageData.h"

@interface ADJAttributionResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                 attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJAttributionPackageData *sourceAttributionPackageData;

@end
