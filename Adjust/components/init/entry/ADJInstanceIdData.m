//
//  ADJInstanceIdData.m
//  Adjust
//
//  Created by Pedro Silva on 19.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJInstanceIdData.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kDefaultId = @"";
static NSString *const kDbNameBase = @"adjust";

#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) NSString *idString;
 */

@implementation ADJInstanceIdData
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId {
    self = [super init];

    _idString = [[ADJInstanceIdData toIdStringWithClientId:clientId] copy];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// public api
- (nonnull NSString *)toDbName {
    if ([self.idString isEqualToString:kDefaultId]) {
        return [NSString stringWithFormat:@"%@.db", kDbNameBase];
    }

    return [NSString stringWithFormat:@"%@_%@.db",
            kDbNameBase, [ADJUtilF normaliseFilename:self.idString]];
}

+ (nonnull NSString *)toIdStringWithClientId:(nullable NSString *)clientId {
    return clientId ?: kDefaultId;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return self.idString;
}

- (NSUInteger)hash {
    return [self.idString hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJInstanceIdData class]]) {
        return NO;
    }

    ADJInstanceIdData *other = (ADJInstanceIdData *)object;
    return [ADJUtilObj objectEquals:self.idString other:other.idString];
}

@end
