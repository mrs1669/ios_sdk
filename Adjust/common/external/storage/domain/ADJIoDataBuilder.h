//
//  ADJIoDataBuilder.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJNonEmptyString.h"
#import "ADJStringMapBuilder.h"

@interface ADJIoDataBuilder : NSObject
// instantiation
- (nonnull instancetype)initWithMetadataTypeValue:
    (nonnull NSString *)metadataTypeValue NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic)
    NSMutableDictionary<NSString *, ADJStringMapBuilder *> *mapCollectionByNameBuilder;
@property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *metadataMapBuilder;
@property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *propertiesMapBuilder;

// public api
- (nullable ADJNonEmptyString *)addEntryToMapByName:(nonnull NSString *)mapName
                                                 key:(nonnull NSString *)key
                                               value:(nullable ADJNonEmptyString *)value;

- (nonnull ADJStringMapBuilder *)addAndReturnNewMapBuilderByName:(nonnull NSString *)mapName;

@end

