//
//  ADJUtilJson.h
//  Adjust
//
//  Created by Pedro Silva on 11.04.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResult.h"
#import "ADJNonEmptyString.h"
#import "ADJOptionalFails.h"

/*
 Json Foundation objects are the Foundation Objects that have equivalence with Json

 To convert a Foundation object to JSON, the object must have the following properties:
 The top level object is an NSArray or NSDictionary
 All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
 All dictionary keys are instances of NSString.
 Numbers are neither NaN or infinity.
 */
@interface ADJUtilJson : NSObject

+ (nonnull ADJResult<NSDictionary<NSString *, id> *> *)
    toDictionaryFromData:(nonnull NSData *)jsonData;
+ (nonnull ADJResult<NSString *> *)toStringFromData:(nonnull NSData *)jsonData;

+ (nonnull ADJOptionalFails<NSString *> *)toStringFromDictionary:
    (nonnull NSDictionary<NSString *, id> *)jsonDictionary;
+ (nonnull ADJOptionalFails<NSString *> *)toStringFromArray:(nonnull NSArray<id> *)jsonArray;

+ (nonnull ADJResult<NSDictionary<NSString *, id> *> *)
    toDictionaryFromString:(nonnull NSString *)jsonString;

+ (nonnull ADJOptionalFails<NSDictionary<NSString *, id> *> *)
    toJsonDictionary:(nonnull NSDictionary *)dictionary;

@end
