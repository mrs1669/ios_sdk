//
//  ADJAdjustAttribution.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustAttribution : NSObject

@property (nullable, strong, nonatomic) NSString *trackerToken;
@property (nullable, strong, nonatomic) NSString *trackerName;
@property (nullable, strong, nonatomic) NSString *network;
@property (nullable, strong, nonatomic) NSString *campaign;
@property (nullable, strong, nonatomic) NSString *adgroup;
@property (nullable, strong, nonatomic) NSString *creative;
@property (nullable, strong, nonatomic) NSString *clickLabel;
@property (nullable, strong, nonatomic) NSString *deeplink;
@property (nullable, strong, nonatomic) NSString *state;
@property (nullable, strong, nonatomic) NSString *costType;
@property (nullable, strong, nonatomic) NSNumber *costAmount;
@property (nullable, strong, nonatomic) NSString *costCurrency;

@end

