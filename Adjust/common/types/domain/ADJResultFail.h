//
//  ADJResultFail.h
//  Adjust
//
//  Created by Pedro Silva on 01.03.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJResultFail <NSObject>

@property (nullable, readonly, strong, nonatomic) NSString *message;
@property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *params;
@property (nullable, readonly, strong, nonatomic) NSError *error;
@property (nullable, readonly, strong, nonatomic) NSException *exception;

- (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

@end

/*
@interface ADJResultFail : NSObject

@property (nonnull, readonly, strong, nonatomic) NSString *message;
@property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, id> *params;
@property (nullable, readonly, strong, nonatomic) NSError *error;
@property (nullable, readonly, strong, nonatomic) NSException *exception;

- (nonnull NSDictionary<NSString *, id> *)foundationDictionary;

@end
*/
