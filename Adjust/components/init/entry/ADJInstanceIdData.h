//
//  ADJInstanceIdData.h
//  Adjust
//
//  Created by Pedro Silva on 19.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJInstanceIdData : NSObject
// instantiation
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSString *idString;

// public api
- (nonnull NSString *)toDbName;

+ (nonnull NSString *)toIdStringWithClientId:(nullable NSString *)clientId;

@end
