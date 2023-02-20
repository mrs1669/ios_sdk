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

- (nonnull instancetype)initFirstInstanceWithClientId:(nullable NSString *)clientId {
    return [self initWithClientId:clientId isFirstInstance:YES];
}
- (nonnull instancetype)initNonFirstWithClientId:(nullable NSString *)clientId {
    return [self initWithClientId:clientId isFirstInstance:NO];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private Constructors
- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId
                         isFirstInstance:(BOOL)isFirstInstance
{
    self = [super init];

    _idString = [[ADJInstanceIdData toIdStringWithClientId:clientId] copy];
    _isFirstInstance = isFirstInstance;

    return self;
}

#pragma mark Public API
+ (nonnull NSString *)toDbNameWithIdString:(nonnull NSString *)idString {
    if ([idString isEqualToString:kDefaultId]) {
        return [NSString stringWithFormat:@"%@.db", kDbNameBase];
    }

    return [NSString stringWithFormat:@"%@_%@.db",
            kDbNameBase, [ADJUtilF normaliseFilename:idString]];
}

- (nonnull NSString *)toDbName {
    return [ADJInstanceIdData toDbNameWithIdString:self.idString];
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
