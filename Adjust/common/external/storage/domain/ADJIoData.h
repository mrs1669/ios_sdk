//
//  ADJIoData.h
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJIoDataBuilder.h"
#import "ADJNonEmptyString.h"
#import "ADJStringMap.h"
#import "ADJLogger.h"

@interface ADJIoData : NSObject
// instantiation
- (nonnull instancetype)initWithIoDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder
    NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJStringMap *metadataMap;
@property (nonnull, readonly, strong, nonatomic) ADJStringMap *propertiesMap;
@property (nonnull, readonly, strong, nonatomic)
    NSDictionary<NSString *, ADJStringMap *> *mapCollectionByName;

// public api
- (nullable ADJStringMap *)mapWithName:(nonnull NSString *)mapName;

- (BOOL)isExpectedMetadataTypeValue:(nonnull NSString *)expectedMetadataTypeValue
                             logger:(nonnull ADJLogger *)logger;

@end
