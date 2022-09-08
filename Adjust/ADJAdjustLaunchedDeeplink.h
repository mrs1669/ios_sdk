//
//  ADJAdjustLaunchedDeeplink.h
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustLaunchedDeeplink : NSObject
// instantiation
- (nonnull instancetype)initWithUrl:(nonnull NSURL *)deeplinkUrl;

- (nonnull instancetype)initWithString:(nonnull NSString *)deeplinkString;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) NSURL *urlDeeplink;
@property (nullable, readonly, strong, nonatomic) NSString *stringDeeplink;

@end
