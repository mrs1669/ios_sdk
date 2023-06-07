//
//  ADJEventDeduplicationData.m
//  Adjust
//
//  Created by Aditi Agrawal on 02/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventDeduplicationData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *deduplicationId;
 */

#pragma mark - Public constants
NSString *const ADJEventDeduplicationDataMetadataTypeValue = @"EventDeduplicationData";

#pragma mark - Private constants
static NSString *const kDeduplicationIdKey = @"deduplicationId";

@implementation ADJEventDeduplicationData
#pragma mark Instantiation
+ (nonnull ADJResultNN<ADJEventDeduplicationData *> *)
    instanceFromIoData:(nonnull ADJIoData *)ioData
{
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJEventDeduplicationDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResultNN failWithMessage:@"Cannot create event deduplication data from io data"
                                        key:@"unexpected metadata type value fail"
                                  otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJNonEmptyString *_Nullable deduplicationId =
        [ioData.propertiesMap pairValueWithKey:kDeduplicationIdKey];
    
    if (deduplicationId == nil) {
        return [ADJResultNN failWithMessage:
                @"Cannot create event deduplication data from io data without its id"];
    }

    return [ADJResultNN okWithValue:[[ADJEventDeduplicationData alloc]
                                     initWithDeduplicationId:deduplicationId]];
}

+ (nonnull ADJOptionalFailsNL<NSArray<ADJEventDeduplicationData *> *> *)
    instanceArrayFromV4WithActivityState:(nullable ADJV4ActivityState *)v4ActivityState
{
    if (v4ActivityState == nil || v4ActivityState.transactionIds == nil) {
        return [[ADJOptionalFailsNL alloc] initWithOptionalFails:nil value:nil];
    }

    NSMutableArray<ADJResultFail *> *_Nonnull optionalFailsMut = [[NSMutableArray alloc] init];
    NSMutableArray<ADJEventDeduplicationData *> *_Nonnull dedupsArrayMut =
        [[NSMutableArray alloc] init];

    for (id _Nonnull transactionIdObject in v4ActivityState.transactionIds) {
        ADJResultNN<ADJNonEmptyString *> *_Nonnull transactionIdResult =
            [ADJNonEmptyString instanceFromObject:transactionIdObject];

        if (transactionIdResult.fail != nil) {
            [optionalFailsMut addObject:
             [[ADJResultFail alloc]
              initWithMessage:@"Invalid value from v4 activity state transactionIds"
              key:@"transaction id object fail"
              otherFail:transactionIdResult.fail]];
        } else {
            [dedupsArrayMut addObject:[[ADJEventDeduplicationData alloc]
                                       initWithDeduplicationId:transactionIdResult.value]];
        }
    }

    if ([dedupsArrayMut count] == 0) {
        return [[ADJOptionalFailsNL alloc]
                initWithOptionalFails:optionalFailsMut
                value:nil];
    }

    return [[ADJOptionalFailsNL alloc] initWithOptionalFails:optionalFailsMut
                                                       value:dedupsArrayMut];
}

- (nonnull instancetype)initWithDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId {
    self = [super init];
    
    _deduplicationId = deduplicationId;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJEventDeduplicationDataMetadataTypeValue];
    
    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kDeduplicationIdKey
     ioValueSerializable:self.deduplicationId];
    
    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJEventDeduplicationDataMetadataTypeValue,
            kDeduplicationIdKey, self.deduplicationId,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + self.deduplicationId.hash;
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJEventDeduplicationData class]]) {
        return NO;
    }
    
    ADJEventDeduplicationData *other = (ADJEventDeduplicationData *)object;
    return [ADJUtilObj objectEquals:self.deduplicationId other:other.deduplicationId];
}

@end
