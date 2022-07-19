//
//  ADJIoDataBuilder.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJIoDataBuilder.h"
#import "ADJConstants.h"
#import "ADJUtilMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readwrite, strong, nonatomic)
     NSMutableDictionary<NSString *, ADJStringMapBuilder *> *mapCollectionByNameBuilder;
 @property (nonnull, readwrite, strong, nonatomic) ADJStringMapBuilder *metadataMapBuilder;
 @property (nonnull, readwrite, strong, nonatomic) ADJStringMapBuilder *propertiesMapBuilder;
 */

@implementation ADJIoDataBuilder

#pragma mark Instantiation

- (nonnull instancetype)initWithMetadataTypeValue:(nonnull NSString *)metadataTypeValue {
    self = [super init];

    _mapCollectionByNameBuilder = [[NSMutableDictionary alloc] init];

    // add current metadata
    ADJStringMapBuilder *_Nonnull metadataMapBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    [metadataMapBuilder addPairWithConstValue:ADJMetadataVersionValue
                                          key:ADJMetadataVersionKey];
    [metadataMapBuilder addPairWithConstValue:metadataTypeValue
                                          key:ADJMetadataIoDataTypeKey];

    [_mapCollectionByNameBuilder setObject:metadataMapBuilder
                                    forKey:ADJMetadataMapName];

    ADJStringMapBuilder *_Nonnull propertiesMapBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    [_mapCollectionByNameBuilder setObject:propertiesMapBuilder
                                    forKey:ADJPropertiesMapName];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API

- (nonnull ADJStringMapBuilder *)metadataMapBuilder {
    return [self.mapCollectionByNameBuilder objectForKey:ADJMetadataMapName];
}

- (nonnull ADJStringMapBuilder *)propertiesMapBuilder {
    return [self.mapCollectionByNameBuilder objectForKey:ADJPropertiesMapName];
}

- (nullable ADJNonEmptyString *)addEntryToMapByName:(nonnull NSString *)mapName
                                                 key:(nonnull NSString *)key
                                               value:(nullable ADJNonEmptyString *)value
{
    if (value == nil) {
        return nil;
    }

    ADJStringMapBuilder *_Nonnull mapBuilder = [self addAndReturnNewMapBuilderByName:mapName];

    return [mapBuilder addPairWithValue:value key:key];
}

- (nonnull ADJStringMapBuilder *)addAndReturnNewMapBuilderByName:(nonnull NSString *)mapName {
    // check if it's already present
    ADJStringMapBuilder *_Nullable mapBuilderWithNamePresent =
        [self.mapCollectionByNameBuilder objectForKey:mapName];

    // and return it, if so
    if (mapBuilderWithNamePresent != nil) {
        return mapBuilderWithNamePresent;
    }

    // otherwise, create a new map
    ADJStringMapBuilder *_Nonnull newMapBuilder =
        [[ADJStringMapBuilder alloc] initWithEmptyMap];

    // and add it
    [self.mapCollectionByNameBuilder setObject:newMapBuilder forKey:mapName];

    return newMapBuilder;
}

#pragma mark Internal Methods

@end
