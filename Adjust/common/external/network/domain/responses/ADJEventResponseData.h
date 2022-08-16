//
//  ADJEventResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 16/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJEventPackageData.h"

@interface ADJEventResponseData : ADJSdkResponseBaseData
// instantiation
- (nonnull instancetype)initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
                       eventPackageData:(nonnull ADJEventPackageData *)eventPackageData
                                 logger:(nonnull ADJLogger *)logger;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJEventPackageData *sourceEventPackage;

@end

