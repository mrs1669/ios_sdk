//
//  ADJAdjustAttribution.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustAttribution : NSObject

@property (nonnull, strong, nonatomic) NSString *trackerToken;
@property (nonnull, strong, nonatomic) NSString *trackerName;
@property (nonnull, strong, nonatomic) NSString *network;
@property (nonnull, strong, nonatomic) NSString *campaign;
@property (nonnull, strong, nonatomic) NSString *adgroup;
@property (nonnull, strong, nonatomic) NSString *creative;
@property (nonnull, strong, nonatomic) NSString *clickLabel;
@property (nonnull, strong, nonatomic) NSString *adid;
@property (nonnull, strong, nonatomic) NSString *deeplink;
@property (nonnull, strong, nonatomic) NSString *state;
@property (nonnull, strong, nonatomic) NSString *costType;
@property (assign, nonatomic) double costAmount;
@property (nonnull, strong, nonatomic) NSString *costCurrency;

@end

