//
//  ADJUtilObj.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJUtilObj.h"

#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kKeyValuesEqualsFormat = @"%@ = %@";
static NSString *const kCStringKeyValuesFormat = @"\n\t%-30s %@";

@implementation ADJUtilObj

+ (nonnull id)copyStringForCollectionWithInput:(nullable id)inputValue {
    NSString *_Nullable sanitizedString = [self copyStringWithInput:inputValue];
    if (sanitizedString == nil) {
        return [NSNull null];
    }
    
    return sanitizedString;
}

+ (nullable NSString *)copyStringWithInput:(nullable id)inputValue {
    if (inputValue == nil) {
        return nil;
    }
    
    if ([inputValue isKindOfClass:[NSString class]]) {
        return [inputValue copy];
    }
    
    return [inputValue description];
}

+ (nullable id)copyObjectWithInput:(nullable id)inputValue
                       classObject:(nullable Class)classObject {
    if (inputValue == nil) {
        return nil;
    }
    
    if (classObject != nil && ! [inputValue isKindOfClass:classObject]) {
        return nil;
    }
    
    return [inputValue copy];
}

+ (BOOL)objectEquals:(nullable id)one other:(nullable id)other {
    return one == other || [one isEqual:other];
}

+ (NSUInteger)objecNullableHash:(nullable id)object {
    if (object == nil) {
        return 0;
    }
    
    return [object hash];
}

+ (nonnull NSString *)formatInlineKeyValuesWithName:(nonnull NSString *)name, ... {
    NSString *result;
    va_list vaKeyValueList;
    va_start(vaKeyValueList, name);
    
    result = [self formatKeyValuesWithName:name
           formatCStringKeyAndAppendEquals:NO
                             keyValueArray:nil
                       stringKeyDictionary:nil
                            vaKeyValueList:vaKeyValueList];
    
    va_end(vaKeyValueList);
    
    return result;
}
+ (nonnull NSString *)formatInlineKeyValuesWithName:(nonnull NSString *)name
                                      keyValueArray:(nonnull NSArray<NSString *> *)keyValueArray {
    return [self formatKeyValuesWithName:name
         formatCStringKeyAndAppendEquals:NO
                           keyValueArray:keyValueArray
                     stringKeyDictionary:nil
                          vaKeyValueList:nil];
}

+ (nonnull NSString *)formatInlineKeyValuesWithName:(nonnull NSString *)name
                                stringKeyDictionary:(nonnull NSDictionary<NSString *, id> *)stringKeyDictionary {
    return [self formatKeyValuesWithName:name
         formatCStringKeyAndAppendEquals:NO
                           keyValueArray:nil
                     stringKeyDictionary:stringKeyDictionary
                          vaKeyValueList:nil];
}

+ (nonnull NSString *)formatNewlineKeyValuesWithName:(nonnull NSString *)name, ... {
    NSString *result;
    va_list vaKeyValueList;
    va_start(vaKeyValueList, name);
    
    result = [self formatKeyValuesWithName:name
           formatCStringKeyAndAppendEquals:YES
                             keyValueArray:nil
                       stringKeyDictionary:nil
                            vaKeyValueList:vaKeyValueList];
    
    va_end(vaKeyValueList);
    
    return result;
}
+ (nonnull NSString *)formatNewlineKeyValuesWithName:(nonnull NSString *)name
                                       keyValueArray:(nonnull NSArray<NSString *> *)keyValueArray {
    return [self formatKeyValuesWithName:name
         formatCStringKeyAndAppendEquals:YES
                           keyValueArray:keyValueArray
                     stringKeyDictionary:nil
                          vaKeyValueList:nil];
}

+ (nonnull NSString *)formatNewlineKeyValuesWithName:(nonnull NSString *)name
                                 stringKeyDictionary:(nonnull NSDictionary<NSString *, id> *)stringKeyDictionary {
    return [self formatKeyValuesWithName:name
         formatCStringKeyAndAppendEquals:YES
                           keyValueArray:nil
                     stringKeyDictionary:stringKeyDictionary
                          vaKeyValueList:nil];
}

#pragma mark Internal Methods
+ (nonnull NSString *)formatKeyValuesWithName:(nonnull NSString *)name
              formatCStringKeyAndAppendEquals:(BOOL)formatCStringKeyAndAppendEquals
                                keyValueArray:(nullable NSArray<NSString *> *)keyValueArray
                          stringKeyDictionary:(nullable NSDictionary<NSString *, id> *)stringKeyDictionary
                               vaKeyValueList:(va_list)vaKeyValueList {
    NSMutableString *_Nonnull sb = [NSMutableString stringWithFormat:@"%@ {", name];
    
    if (keyValueArray != nil && (keyValueArray.count % 2) != 0) {
        [sb appendFormat:@"Invalid array key value of size %@}",
         [ADJUtilF uIntegerFormat:keyValueArray.count]];
        return (NSString *_Nonnull)sb;
    }
    
    NSMutableString *_Nullable emptyKeysSb = nil;
    BOOL hasAtLeastOneKeyValuePair = NO;
    
    NSUInteger arrayIndex = 0;
    
    NSUInteger stringKeyArrayIndex = 0;
    NSArray<NSString *> *_Nullable stringKeyArray = nil;
    if (stringKeyDictionary != nil) {
        stringKeyArray = stringKeyDictionary.allKeys;
    }
    
    NSString *key = nil;
    if (keyValueArray != nil) {
        key = keyValueArray.count > arrayIndex ? [keyValueArray objectAtIndex:arrayIndex] : nil;
    } else if (stringKeyArray != nil) {
        key = stringKeyArray.count > stringKeyArrayIndex ?
        [stringKeyArray objectAtIndex:stringKeyArrayIndex] : nil;
    } else {
        key = va_arg(vaKeyValueList, NSString *);
    }
    
    while (key != nil) {
        id value = nil;
        
        if (keyValueArray != nil) {
            value = [keyValueArray objectAtIndex:(arrayIndex + 1)];
        } else if (stringKeyArray != nil) {
            value = [stringKeyDictionary objectForKey:key];
        } else {
            value = va_arg(vaKeyValueList, id);
        }
        
        if (value == nil) {
            if (emptyKeysSb == nil) {
                emptyKeysSb = [NSMutableString stringWithFormat:@"[%@", key];
            } else {
                [emptyKeysSb appendFormat:@", %@", key];
            }
            
            if (keyValueArray != nil) {
                arrayIndex = arrayIndex + 2;
                key = keyValueArray.count > arrayIndex ?
                [keyValueArray objectAtIndex:arrayIndex] : nil;
            } else if (stringKeyArray != nil) {
                stringKeyArrayIndex = stringKeyArrayIndex + 1;
                key = stringKeyArray.count > stringKeyArrayIndex ?
                [stringKeyArray objectAtIndex:stringKeyArrayIndex] : nil;
            } else {
                key = va_arg(vaKeyValueList, NSString *);
            }
            
            continue;
        }
        
        if (hasAtLeastOneKeyValuePair) {
            [sb appendString:@", "];
        }
        
        if (formatCStringKeyAndAppendEquals) {
            [sb appendFormat:kCStringKeyValuesFormat,
             [[NSString stringWithFormat:@"%@ =", key] UTF8String],
             value];
        } else {
            [sb appendFormat:kKeyValuesEqualsFormat, key, value];
        }
        
        hasAtLeastOneKeyValuePair = YES;
        
        if (keyValueArray != nil) {
            arrayIndex = arrayIndex + 2;
            key = keyValueArray.count > arrayIndex ?
            [keyValueArray objectAtIndex:arrayIndex] : nil;
        } else if (stringKeyArray != nil) {
            stringKeyArrayIndex = stringKeyArrayIndex + 1;
            key = stringKeyArray.count > stringKeyArrayIndex ?
            [stringKeyArray objectAtIndex:stringKeyArrayIndex] : nil;
        } else {
            key = va_arg(vaKeyValueList, NSString *);
        }
    }
    
    [sb appendString:@"}"];
    
    if (emptyKeysSb != nil) {
        [emptyKeysSb appendString:@"]"];
        
        if (formatCStringKeyAndAppendEquals) {
            [sb appendFormat:kCStringKeyValuesFormat,
             [@" Without value =" UTF8String],
             emptyKeysSb];
        } else {
            [sb appendFormat:kKeyValuesEqualsFormat, @" Without value", emptyKeysSb];
        }
    }
    
    return (NSString *_Nonnull)sb;
}

@end
