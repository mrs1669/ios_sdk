//
//  ADJUtilF.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimestampMilli.h"
//#import "ADJMoney.h"
#import "ADJLogger.h"

@interface ADJUtilF : NSObject

+ (nonnull NSLocale *)usLocale;
+ (nonnull NSNumberFormatter *)decimalStyleFormatter;

+ (nonnull NSString *)boolFormat:(BOOL)boolValue;
+ (nonnull NSString *)intFormat:(int)intValue;
+ (nonnull NSString *)uIntFormat:(unsigned int)uIntValue;
+ (nonnull NSString *)uLongFormat:(unsigned long)uLongValue;
+ (nonnull NSString *)uLongLongFormat:(unsigned long long)uLongLongValue;
+ (nonnull NSString *)integerFormat:(NSInteger)integerValue;
+ (nonnull NSString *)uIntegerFormat:(NSUInteger)uIntegerFormat;
+ (nonnull NSString *)longLongFormat:(long long)longLongValue;

+ (nonnull NSString *)errorFormat:(nonnull NSError *)error;

+ (nullable NSString *)jsonDataFormat:(nonnull NSData *)jsonData;
+ (nullable NSString *)jsonFoundationValueFormat:(nonnull id)jsonFoundationValue;

+ (nonnull NSString *)secondsFormat:(nonnull NSNumber *)secondsNumber;

+ (nonnull NSString *)dateTimestampFormat:(nonnull ADJTimestampMilli *)timestamp;

+ (BOOL)matchesWithString:(nonnull NSString *)stringValue
                    regex:(nonnull NSRegularExpression *)regex;

+ (BOOL)isNotANumber:(nonnull NSNumber *)numberValue;

+ (nullable NSString *)urlReservedEncodeWithSpaceAsPlus:(nonnull NSString *)stringToEncode;

+ (nonnull NSString *)joinString:(nonnull NSString *)first, ...;

// TODO: (Gena) Why this method declaration was commented out? It's used ADJSessionDeviceIdsData.
+ (nullable NSString *)stringValueOrNil:(nullable ADJNonEmptyString *)value;

//+ (void)
//    transferExternalParametersWithFoundationMapToRead:
//        (nonnull NSDictionary<NSString *, NSString *> *)foundationMapToRead
//    parametersToWrite:(nonnull StringMapBuilder *)parametersToWrite
//    source:(nonnull NSString *)source
//    logger:(nonnull Logger *)logger;

@end

