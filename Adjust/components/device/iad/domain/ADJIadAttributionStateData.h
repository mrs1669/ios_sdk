//
//  ADJ5IadAttributionStateData.h
//  Adjust
//
//  Created by Pedro S. on 31.07.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//
/*
#import <Foundation/Foundation.h>

#import "ADJ5IoDataSerializable.h"
#import "ADJ5IoData.h"
#import "ADJ5Logger.h"
//#import "ADJ5IadAttributionData.h"
#import "ADJ5NonEmptyString.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJ5IadAttributionStateDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJ5IadAttributionStateData : NSObject<ADJ5IoDataSerializable>
// instantiation
+ (nullable instancetype)instanceFromIoData:(nonnull ADJ5IoData *)ioData
                                     logger:(nonnull ADJ5Logger *)logger;

- (nonnull instancetype)initWithIntialState;

- (nonnull instancetype)initWithIadAttributionData:
    (nullable ADJ5IadAttributionData *)iadAttributionData
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
//@property (nullable, readonly, strong, nonatomic) ADJ5IadAttributionData *iadAttributionData;
@property (nullable, readonly, strong, nonatomic) ADJ5NonEmptyString *iadAttributionJsonString;

@end
*/
