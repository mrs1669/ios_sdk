//
//  ADJAdjustPushToken.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdjustPushToken : NSObject
// instantiation
- (nonnull instancetype)initWithDataPushToken:(nonnull NSData *)dataPushToken;

- (nonnull instancetype)initWithStringPushToken:(nonnull NSString *)stringPushToken;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) NSData *dataPushToken;
@property (nullable, readonly, strong, nonatomic) NSString *stringPushToken;

@end
