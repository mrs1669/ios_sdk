//
//  ADJSdkResponseData.h
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkPackageData.h"
#import "ADJTimeLengthMilli.h"
#import "ADJNonEmptyString.h"

@protocol ADJSdkResponseData <NSObject>

// public properties
@property (readonly, assign, nonatomic) BOOL shouldRetry;
@property (readonly, assign, nonatomic) BOOL processedByServer;
@property (readonly, assign, nonatomic) BOOL hasBeenOptOut;

@property (nonnull, readonly, strong, nonatomic) id<ADJSdkPackageData> sourcePackage;

@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *retryIn;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *continueIn;
@property (nullable, readonly, strong, nonatomic) ADJTimeLengthMilli *askIn;

@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *adid;

@property (nullable, strong, nonatomic) NSDictionary *attributionJson;

@end
