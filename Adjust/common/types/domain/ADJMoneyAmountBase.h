//
//  ADJMoneyAmountBase.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJLogger.h"

@interface ADJMoneyAmountBase : NSObject<
    NSCopying,
    ADJPackageParamValueSerializable,
    ADJIoValueSerializable
>
// instantiation
+ (nullable instancetype)instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
                                      logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromOptionalIoValue:(nullable ADJNonEmptyString *)ioValue
                                              logger:(nonnull ADJLogger *)logger;

- (nonnull instancetype)init;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *numberValue;
@property (readonly, assign, nonatomic) double doubleValue;

@end

