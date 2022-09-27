//
//  ADJClickResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJClickPackageData.h"

@interface ADJClickResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                       clickPackageData:(nonnull ADJClickPackageData *)clickPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJClickPackageData *sourceClickPackageData;

@end
