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
