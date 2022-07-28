//
//  ADJMoneyAmountBase.m
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJMoneyAmountBase.h"

#import "ADJUtilF.h"
#import "ADJConstants.h"
#import "ADJMoneyDoubleAmount.h"
#import "ADJMoneyDecimalAmount.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSNumber *numberValue;
 @property (readonly, assign, nonatomic) double doubleValue;
 */

@implementation ADJMoneyAmountBase
#pragma mark Instantiation
+ (nullable instancetype)instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
                                      logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIoValue:ioValue
                              logger:logger
                          isOptional:NO];
}

+ (nullable instancetype)instanceFromOptionalIoValue:(nullable ADJNonEmptyString *)ioValue
                                              logger:(nonnull ADJLogger *)logger {
    return [self instanceFromIoValue:ioValue
                              logger:logger
                          isOptional:YES];
}

- (nonnull instancetype)init {
    // prevents direct creation of instance, needs to be invoked by subclass
    if ([self isMemberOfClass:[ADJMoneyAmountBase class]]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    
    self = [super init];
    
    return self;
}

#pragma mark - Private constructors
+ (nullable instancetype)instanceFromIoValue:(nullable ADJNonEmptyString *)ioValue
                                      logger:(nonnull ADJLogger *)logger
                                  isOptional:(BOOL)isOptional {
    if (ioValue == nil) {
        if (! isOptional) {
            [logger error:@"Cannot create money amount with nil string value"];
        }
        return nil;
    }
    
    if ([ioValue.stringValue hasPrefix:@"llf"]) {
        return [ADJMoneyDoubleAmount
                instanceFromIoLlfValue:[ioValue.stringValue substringFromIndex:3]
                logger:logger];
    }
    
    if ([ioValue.stringValue hasPrefix:@"dec"]) {
        return [ADJMoneyDecimalAmount
                instanceFromIoDecValue:[ioValue.stringValue substringFromIndex:3]
                logger:logger];
    }
    
    [logger error:@"Cannot create money amount without a valid io data value prefix in %@", ioValue];
    
    return nil;
}

#pragma mark Public API
#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

@end
