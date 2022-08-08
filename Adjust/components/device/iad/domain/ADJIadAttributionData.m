//
//  ADJ5IadAttributionData.m
//  Adjust
//
//  Created by Pedro S. on 30.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//
/*

#import "ADJ5IadAttributionData.h"

#import "ADJ5UtilObj.h"
#import "ADJ5UtilMap.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJ5IadAttributionDataMetadataTypeValue = @"IadAttributionData";

#pragma mark - Private constants
static NSString *const kIadAttributionDetailsKey = @"iadAttributionDetails";

@interface ADJ5IadAttributionData ()
#pragma mark - Injected dependencies
//@property (nonnull, readonly, strong, nonatomic)
//    NSDictionary<NSString *,NSObject *> *iadAttributionDetails;
@property (nonnull, readonly, strong, nonatomic) ADJ5NonEmptyString *detailsString;

@end

@implementation ADJ5IadAttributionData
#pragma mark Instantiation
- (nonnull instancetype)initWithIadAttributionDetails:
    (nonnull NSDictionary<NSString *,NSObject *> *)iadAttributionDetails
{
    self = [super init];

    // _iadAttributionDetails = iadAttributionDetails;
    _detailsString = [ADJ5IadAttributionData detailsStringWithExternal];

    return self;
}


#pragma mark Public API
- (nonnull NSDictionary<NSString *,NSObject *> *)copyIadAttributionDetails {
    return [[NSDictionary alloc] initWithDictionary:self.iadAttributionDetails
                                          copyItems:YES];
}

#pragma mark - ADJ5PackageParamValueSerializable
- (nullable ADJ5NonEmptyString *)toParamValue {
    return nil; // TODO
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJ5UtilObj formatInlineKeyValuesWithName:
                ADJ5IadAttributionDataMetadataTypeValue,
                    kIadAttributionDetailsKey, self.trackerToken,
                nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJ5InitialHashCode;

    hashCode = ADJ5HashCodeMultiplier * hashCode +
        [ADJ5UtilObj objecNullableHash:self.trackerToken];
    hashCode = ADJ5HashCodeMultiplier * hashCode +
        [ADJ5UtilObj objecNullableHash:self.trackerName];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.network];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.campaign];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.adgroup];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.creative];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.clickLabel];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.adid];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.deeplink];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.state];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.costType];
    hashCode = ADJ5HashCodeMultiplier * hashCode + [ADJ5UtilObj objecNullableHash:self.costAmount];
    hashCode = ADJ5HashCodeMultiplier * hashCode +
        [ADJ5UtilObj objecNullableHash:self.costCurrency];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJ5IadAttributionData class]]) {
        return NO;
    }

    ADJ5IadAttributionData *other = (ADJ5IadAttributionData *)object;
    return [ADJ5UtilObj objectEquals:self.trackerToken other:other.trackerToken]
        && [ADJ5UtilObj objectEquals:self.trackerName other:other.trackerName]
        && [ADJ5UtilObj objectEquals:self.network other:other.network]
        && [ADJ5UtilObj objectEquals:self.campaign other:other.campaign]
        && [ADJ5UtilObj objectEquals:self.adgroup other:other.adgroup]
        && [ADJ5UtilObj objectEquals:self.creative other:other.creative]
        && [ADJ5UtilObj objectEquals:self.clickLabel other:other.clickLabel]
        && [ADJ5UtilObj objectEquals:self.adid other:other.adid]
        && [ADJ5UtilObj objectEquals:self.deeplink other:other.deeplink]
        && [ADJ5UtilObj objectEquals:self.state other:other.state]
        && [ADJ5UtilObj objectEquals:self.costType other:other.costType]
        && [ADJ5UtilObj objectEquals:self.costAmount other:other.costAmount]
        && [ADJ5UtilObj objectEquals:self.costCurrency other:other.costCurrency];
}
#pragma mark Internal Methods

@end
 */
