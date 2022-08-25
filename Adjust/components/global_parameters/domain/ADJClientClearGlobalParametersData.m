//
//  ADJClientClearGlobalParametersData.m
//  Adjust
//
//  Created by Aditi Agrawal on 25/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClientClearGlobalParametersData.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJClientActionData.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJClientClearGlobalParametersDataMetadataTypeValue = @"ClientClearGlobalParametersData";

@implementation ADJClientClearGlobalParametersData
#pragma mark Instantiation
+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger {
    ADJNonEmptyString *_Nullable clientActionTypeValue = [clientActionInjectedIoData.metadataMap
                                                          pairValueWithKey:ADJClientActionTypeKey];

    if (clientActionTypeValue == nil) {
        [logger error:@"Cannot create ClientClearGlobalParametersData"
         " instance from client action io data without client action type value"];
        return nil;
    }

    if (! [ADJClientClearGlobalParametersDataMetadataTypeValue isEqualToString:clientActionTypeValue.stringValue]) {
        [logger error:@"Cannot create ClientClearGlobalParametersData"
         " instance from client action io data"
         " with read client action type value %@"
         " different than expected %@",
         clientActionInjectedIoData, ADJClientClearGlobalParametersDataMetadataTypeValue];
        return nil;
    }

    return [[self alloc] init];
}

- (nullable instancetype)init {
    self = [super init];

    return self;
}

#pragma mark Public API
#pragma mark - ADJClientActionIoDataInjectable
- (void)injectIntoClientActionIoDataBuilder:(nonnull ADJIoDataBuilder *)clientActionIoDataBuilder {
    ADJStringMapBuilder *_Nonnull metadataMapBuilder = clientActionIoDataBuilder.metadataMapBuilder;

    // add client action type to metadata map to distinguish between add/remove/clear
    //  when handler needs to deserialize and reconstruct data
    [ADJUtilMap injectIntoIoDataBuilderMap:metadataMapBuilder
                                       key:ADJClientActionTypeKey
                                constValue:ADJClientClearGlobalParametersDataMetadataTypeValue];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJClientClearGlobalParametersDataMetadataTypeValue,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJClientClearGlobalParametersData class]]) {
        return NO;
    }

    //ADJClientClearGlobalParametersData *other = (ADJClientClearGlobalParametersData *)object;
    return YES;
}

@end
