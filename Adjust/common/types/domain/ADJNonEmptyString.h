//
//  ADJNonEmptyString.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJLogger.h"

@interface ADJNonEmptyString : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nullable instancetype)instanceFromString:(nullable NSString *)stringValue
                          sourceDescription:(nonnull NSString *)sourceDescription
                                     logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalString:(nullable NSString *)stringValue
                                  sourceDescription:(nonnull NSString *)sourceDescription
                                             logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)initWithConstStringValue:(nonnull NSString *)constStringValue
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *stringValue;

@end
