//
//  ADJSessionDeviceIdsData.m
//  Adjust
//
//  Created by Pedro S. on 26.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSessionDeviceIdsData.h"

#import "ADJUtilF.h"
#import "ADJAdjustInternal.h"
#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *advertisingIdentifier;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *identifierForVendor;
 */

#pragma mark - Private constants
static NSString *const kAdvertisingIdentifierKey = @"advertisingIdentifier";
static NSString *const kIdentifierForVendorKey = @"identifierForVendor";

@implementation ADJSessionDeviceIdsData
#pragma mark Instantiation
- (nonnull instancetype)
    initWithAdvertisingIdentifier:(nullable ADJNonEmptyString *)advertisingIdentifier
    identifierForVendor:(nullable ADJNonEmptyString *)identifierForVendor
{
    self = [super init];

    _advertisingIdentifier = advertisingIdentifier;
    _identifierForVendor = identifierForVendor;

    return self;
}
/*
- (nonnull instancetype)initWithFailMessage:(nullable NSString *)failMessage {
    return [self initWithFailMessage:failMessage
               advertisingIdentifier:nil
                 identifierForVendor:nil];
}
*/
- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
/*
- (nonnull instancetype)initWithFailMessage:(nullable NSString *)failMessage
                      advertisingIdentifier:(nullable ADJNonEmptyString *)advertisingIdentifier
                        identifierForVendor:(nullable ADJNonEmptyString *)identifierForVendor {
    self = [super init];
    
    _failMessage = failMessage;
    _advertisingIdentifier = advertisingIdentifier;
    _identifierForVendor = identifierForVendor;
    
    return self;
}
*/
#pragma mark Public API
- (nonnull ADJAdjustDeviceIds *)toAdjustDeviceIds {
    return [[ADJAdjustDeviceIds alloc]
            initWithAdvertisingIdentifier:[ADJUtilF stringValueOrNil:self.advertisingIdentifier]
            identifierForVendor:[ADJUtilF stringValueOrNil:self.identifierForVendor]];
}

- (nonnull ADJOptionalFailsNN<NSDictionary<NSString *, id> *> *)
    buildInternalCallbackDataWithMethodName:(nonnull NSString *)methodName
{
    NSMutableDictionary<NSString *, id> *_Nonnull callbackDataMut =
        [[NSMutableDictionary alloc] init];

    ADJAdjustDeviceIds *_Nonnull adjustDeviceIds = [self toAdjustDeviceIds];
    [callbackDataMut setObject:adjustDeviceIds
                        forKey:[NSString stringWithFormat:@"%@%@",
                                methodName, ADJInternalCallbackAdjustDataSuffix]];

    NSDictionary<NSString *, id> *_Nonnull jsonDictionary =
        [ADJSessionDeviceIdsData toJsonDictionaryWithAdjustDeviceIds:adjustDeviceIds];
    [callbackDataMut setObject:jsonDictionary
                        forKey:[NSString stringWithFormat:@"%@%@",
                                methodName, ADJInternalCallbackNsDictionarySuffix]];

    ADJOptionalFailsNN<NSString *> *_Nonnull jsonStringOptFails =
        [ADJUtilJson toStringFromDictionary:jsonDictionary];
    [callbackDataMut setObject:jsonStringOptFails.value
                        forKey:[NSString stringWithFormat:@"%@%@",
                                methodName, ADJInternalCallbackJsonStringSuffix]];

    return [[ADJOptionalFailsNN alloc] initWithOptionalFails:jsonStringOptFails.optionalFails
                                                       value:callbackDataMut];
}

+ (nonnull NSDictionary<NSString *, id> *)toJsonDictionaryWithAdjustDeviceIds:
    (nonnull ADJAdjustDeviceIds *)adjustDeviceIds
{
    NSMutableDictionary<NSString *, id> *_Nonnull jsonDictionaryMut =
        [[NSMutableDictionary alloc] initWithCapacity:2];

    [jsonDictionaryMut setObject:[ADJUtilObj idOrNsNull:adjustDeviceIds.advertisingIdentifier]
                          forKey:kAdvertisingIdentifierKey];
    [jsonDictionaryMut setObject:[ADJUtilObj idOrNsNull:adjustDeviceIds.identifierForVendor]
                          forKey:kIdentifierForVendorKey];

    return jsonDictionaryMut;
}

@end
