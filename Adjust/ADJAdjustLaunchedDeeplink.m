//
//  ADJAdjustLaunchedDeeplink.m
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustLaunchedDeeplink.h"

#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSURL *urlDeeplink;
 @property (nullable, readonly, strong, nonatomic) NSString *stringDeeplink;
 */

@implementation ADJAdjustLaunchedDeeplink
#pragma mark Instantiation
- (nonnull instancetype)initWithUrl:(nonnull NSURL *)deeplinkUrl {
    return [self initWithUrlDeeplink:deeplinkUrl
                      stringDeeplink:nil];
}

- (nonnull instancetype)initWithString:(nonnull NSString *)deeplinkString {
    return [self initWithUrlDeeplink:nil
                      stringDeeplink:deeplinkString];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private Constructors
- (nonnull instancetype)initWithUrlDeeplink:(nullable NSURL *)urlDeeplink
                             stringDeeplink:(nullable NSString *)stringDeeplink {
    self = [super init];

    _urlDeeplink = [ADJUtilObj copyObjectWithInput:urlDeeplink
                                       classObject:[NSURL class]];

    _stringDeeplink = [ADJUtilObj copyStringWithInput:stringDeeplink];

    return self;
}

@end

