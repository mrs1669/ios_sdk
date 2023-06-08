//
//  ADJClientActionData.m
//  Adjust
//
//  Created by Pedro S. on 03.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJClientActionData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *clientActionHandlerId;
 @property (nonnull, readonly, strong, nonatomic) ADJTimestampMilli *apiTimestamp;
 @property (nonnull, readonly, strong, nonatomic) ADJIoData *ioData;
 */

#pragma mark - Public constants
NSString *const ADJClientActionDataMetadataTypeValue = @"ClientActionData";
NSString *const ADJClientActionTypeKey = @"clientActionType";

#pragma mark - Private constants
static NSString *const kClientActionHandlerIdKey = @"clientActionHandlerId";
static NSString *const kApiTimestampKey = @"apiTimestamp";
static NSString *const kIoDataKey = @"ioData";

@implementation ADJClientActionData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJClientActionData *> *)instanceWithIoData:(nonnull ADJIoData *)ioData {
    ADJStringMap *_Nonnull metadataMap = ioData.metadataMap;
    
    ADJNonEmptyString *_Nullable clientActionHandlerId =
        [metadataMap pairValueWithKey:kClientActionHandlerIdKey];
    
    if (clientActionHandlerId == nil) {
        return [ADJResult failWithMessage:
                @"Cannot create client action data without client action handler"];
    }
    
    ADJResult<ADJTimestampMilli *> *_Nonnull apiTimestampResult =
        [ADJTimestampMilli instanceFromIoDataValue:
         [metadataMap pairValueWithKey:kApiTimestampKey]];
    if (apiTimestampResult.fail != nil) {
        return [ADJResult failWithMessage:
                @"Cannot create client action data with invalid api timestamp"
                                      key:@"apiTimestamp fail"
                                otherFail:apiTimestampResult.fail];
    }

    return [ADJResult okWithValue:[[ADJClientActionData alloc]
                                   initWithClientActionHandlerId:clientActionHandlerId
                                   apiTimestamp:apiTimestampResult.value
                                   ioData:ioData]];
}

- (nonnull instancetype)initWithClientActionHandlerId:(nonnull ADJNonEmptyString *)clientActionHandlerId
                                         nowTimestamp:(nonnull ADJTimestampMilli *)nowTimestamp
                                        ioDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder {
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.metadataMapBuilder
                                       key:kClientActionHandlerIdKey
                       ioValueSerializable:clientActionHandlerId];
    
    [ADJUtilMap injectIntoIoDataBuilderMap:ioDataBuilder.metadataMapBuilder
                                       key:kApiTimestampKey
                       ioValueSerializable:nowTimestamp];
    
    return [self initWithClientActionHandlerId:clientActionHandlerId
                                  apiTimestamp:nowTimestamp
                                        ioData:[[ADJIoData alloc] initWithIoDataBuilder:
                                                ioDataBuilder]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithClientActionHandlerId:(nonnull ADJNonEmptyString *)clientActionHandlerId
                                         apiTimestamp:(nonnull ADJTimestampMilli *)apiTimestamp
                                               ioData:(nonnull ADJIoData *)ioData {
    self = [super init];
    
    _clientActionHandlerId = clientActionHandlerId;
    _apiTimestamp = apiTimestamp;
    _ioData = ioData;
    
    return self;
}

#pragma mark Public API
#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientActionDataMetadataTypeValue,
            kClientActionHandlerIdKey, self.clientActionHandlerId,
            kApiTimestampKey, self.apiTimestamp,
            kIoDataKey, self.ioData,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + [self.clientActionHandlerId hash];
    hashCode = ADJHashCodeMultiplier * hashCode + [self.apiTimestamp hash];
    hashCode = ADJHashCodeMultiplier * hashCode + [self.ioData hash];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJClientActionData class]]) {
        return NO;
    }
    
    ADJClientActionData *other = (ADJClientActionData *)object;
    return [ADJUtilObj objectEquals:self.clientActionHandlerId other:other.clientActionHandlerId]
    && [ADJUtilObj objectEquals:self.apiTimestamp other:other.apiTimestamp]
    && [ADJUtilObj objectEquals:self.ioData other:other.ioData];
}

@end


