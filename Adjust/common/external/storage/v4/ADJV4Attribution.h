//
//  ADJV4Attribution.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJV4Attribution : NSObject<NSCoding>

@property (nullable, readonly, strong, nonatomic) NSString *trackerToken;
@property (nullable, readonly, strong, nonatomic) NSString *trackerName;
@property (nullable, readonly, strong, nonatomic) NSString *network;
@property (nullable, readonly, strong, nonatomic) NSString *campaign;
@property (nullable, readonly, strong, nonatomic) NSString *adgroup;
@property (nullable, readonly, strong, nonatomic) NSString *creative;
@property (nullable, readonly, strong, nonatomic) NSString *clickLabel;
@property (nullable, readonly, strong, nonatomic) NSString *adid;
@property (nullable, readonly, strong, nonatomic) NSString *costType;
@property (nullable, readonly, strong, nonatomic) NSNumber *costAmount;
@property (nullable, readonly, strong, nonatomic) NSString *costCurrency;

/*
 @property (nonatomic, copy, nullable) NSString *trackerToken;
 @property (nonatomic, copy, nullable) NSString *trackerName;
 @property (nonatomic, copy, nullable) NSString *network;
 @property (nonatomic, copy, nullable) NSString *campaign;
 @property (nonatomic, copy, nullable) NSString *adgroup;
 @property (nonatomic, copy, nullable) NSString *creative;
 @property (nonatomic, copy, nullable) NSString *clickLabel;
 @property (nonatomic, copy, nullable) NSString *adid;
 @property (nonatomic, copy, nullable) NSString *costType;
 @property (nonatomic, copy, nullable) NSNumber *costAmount;
 @property (nonatomic, copy, nullable) NSString *costCurrency;
 */

@end
