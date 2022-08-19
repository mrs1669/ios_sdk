//
//  ADJSessionDeviceIdsData.m
//  Adjust
//
//  Created by Pedro S. on 26.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJSessionDeviceIdsData.h"

#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *failMessage;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *advertisingIdentifier;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *identifierForVendor;
 */

@implementation ADJSessionDeviceIdsData
#pragma mark Instantiation
- (nonnull instancetype)initWithAdvertisingIdentifier:(nullable ADJNonEmptyString *)advertisingIdentifier
                                  identifierForVendor:(nullable ADJNonEmptyString *)identifierForVendor {
    return [self initWithFailMessage:nil
               advertisingIdentifier:advertisingIdentifier
                 identifierForVendor:identifierForVendor];
}
- (nonnull instancetype)initWithFailMessage:(nullable NSString *)failMessage {
    return [self initWithFailMessage:failMessage
               advertisingIdentifier:nil
                 identifierForVendor:nil];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (nonnull instancetype)initWithFailMessage:(nullable NSString *)failMessage
                      advertisingIdentifier:(nullable ADJNonEmptyString *)advertisingIdentifier
                        identifierForVendor:(nullable ADJNonEmptyString *)identifierForVendor {
    self = [super init];
    
    _failMessage = failMessage;
    _advertisingIdentifier = advertisingIdentifier;
    _identifierForVendor = identifierForVendor;
    
    return self;
}

#pragma mark Public API
- (nonnull ADJAdjustDeviceIds *)toAdjustDeviceIds {
    return [[ADJAdjustDeviceIds alloc]
            initWithAdvertisingIdentifier:[ADJUtilF stringValueOrNil:self.advertisingIdentifier]
            identifierForVendor:[ADJUtilF stringValueOrNil:self.identifierForVendor]];
}

@end
