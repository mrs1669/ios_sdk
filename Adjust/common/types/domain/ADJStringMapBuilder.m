//
//  ADJStringMapBuilder.m
//  AdjustV5
//
//  Created by Pedro S. on 13.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJStringMapBuilder.h"
#import "ADJStringMap.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 // @property (nonnull, readwrite, strong, nonatomic)
 //     NSMutableDictionary<NSString *, ADJNonEmptyString*> *mapBuilder;
 */
@interface ADJStringMapBuilder ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
NSMutableDictionary<NSString *, ADJNonEmptyString*> *mapBuilder;

@end

@implementation ADJStringMapBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithEmptyMap {
    return [self initWithMapBuilderDictionary:[[NSMutableDictionary alloc] init]];
}

- (nonnull instancetype)initWithStringMap:(nonnull ADJStringMap *)stringMap {
    return [self initWithMapBuilderDictionary:
            [[NSMutableDictionary alloc] initWithDictionary:stringMap.map]];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
- (nonnull instancetype)initWithMapBuilderDictionary:(nonnull NSMutableDictionary<NSString *, ADJNonEmptyString*> *)mapBuilder {
    self = [super init];
    
    _mapBuilder = mapBuilder;
    
    return self;
}

#pragma mark Public API
- (nullable ADJNonEmptyString *)addPairWithValue:(nonnull ADJNonEmptyString *)value
                                             key:(nonnull NSString *)key {
    ADJNonEmptyString *_Nullable previousValue =
    [self pairValueWithKey:key];
    
    [self.mapBuilder setObject:value forKey:key];
    
    return previousValue;
}

- (nullable ADJNonEmptyString *)addPairWithConstValue:(nonnull NSString *)constValue key:(nonnull NSString *)key {
    return [self addPairWithValue:
            [[ADJNonEmptyString alloc] initWithConstStringValue:constValue]
                              key:key];
}

- (nullable ADJNonEmptyString *)pairValueWithKey:(nonnull NSString *)key {
    return [self.mapBuilder objectForKey:key];
}

- (nullable ADJNonEmptyString *)removePairWithKey:(nonnull NSString *)key {
    ADJNonEmptyString *_Nullable previousValue = [self pairValueWithKey:key];
    
    [self.mapBuilder removeObjectForKey:key];
    
    return previousValue;
}

- (void)addAllPairsWithStringMap:(nonnull ADJStringMap *)stringMap {
    [self.mapBuilder addEntriesFromDictionary:stringMap.map];
}

- (void)addAllPairsWithStringMapBuilder:(nonnull ADJStringMapBuilder *)stringMapBuilder {
    [self.mapBuilder addEntriesFromDictionary:stringMapBuilder.mapBuilder];
}

- (NSUInteger)countPairs {
    return self.mapBuilder.count;
}

- (BOOL)isEmpty {
    return self.mapBuilder.count == 0;
}

- (nonnull NSDictionary<NSString *, ADJNonEmptyString*> *)mapCast {
    return self.mapBuilder;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    return [[ADJStringMapBuilder allocWithZone:zone]
            initWithMapBuilderDictionary:
                [[NSMutableDictionary alloc] initWithDictionary:self.mapBuilder]];
}

@end
