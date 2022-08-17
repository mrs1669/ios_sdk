//
//  ADJAdjustPushToken.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustPushToken.h"

#import "ADJUtilObj.h"

#pragma mark Fields

#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSData *dataPushToken;
 @property (nullable, readonly, strong, nonatomic) NSString *stringPushToken;
 */

@implementation ADJAdjustPushToken

#pragma mark Instantiation
- (nonnull instancetype)initWithDataPushToken:(nonnull NSData *)dataPushToken {
    return [self initWithDataPushToken:dataPushToken stringPushToken:nil];
}

- (nonnull instancetype)initWithStringPushToken:(nonnull NSString *)stringPushToken {
    return [self initWithDataPushToken:nil stringPushToken:stringPushToken];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


#pragma mark - Private Constructors
- (nonnull instancetype)initWithDataPushToken:(nullable NSData *)dataPushToken
                              stringPushToken:(nullable NSString *)stringPushToken {
    self = [super init];
    
    _dataPushToken = [ADJUtilObj copyObjectWithInput:dataPushToken
                                         classObject:[NSData class]];
    _stringPushToken = [ADJUtilObj copyStringWithInput:stringPushToken];
    
    return self;
}

@end

