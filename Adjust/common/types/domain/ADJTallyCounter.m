//
//  ADJTallyCounter.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJTallyCounter.h"

#import "ADJUtilObj.h"
#import "ADJConstants.h"

//#import "ADJResultFail.h"

#pragma mark Fields
#pragma mark - Public properties
/* ADJNonNegativeInt.h
 @property (readonly, assign, nonatomic) NSUInteger nsuIntegerValue;
 */

@implementation ADJTallyCounter
#pragma mark Instantiation
+ (nonnull instancetype)instanceStartingAtZero {
    return [self zeroInstance];
}

+ (nonnull instancetype)instanceStartingAtOne {
    return [self oneInstance];
}

+ (nullable instancetype)
    instanceFromOptionalNonNegativeInt:(nullable ADJNonNegativeInt *)nonNegativeInt
{
    if (nonNegativeInt == nil) {
        return nil;
    }
    
    return [[self alloc] initWithCountValue:nonNegativeInt];
}

+ (nonnull ADJResult<ADJTallyCounter *> *)
    instanceFromIoDataValue:(nullable ADJNonEmptyString *)ioDataValue
{
    ADJResult<ADJNonNegativeInt *> *_Nonnull nnIntResult =
        [ADJNonNegativeInt instanceFromIoDataValue:ioDataValue];
    if (nnIntResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create tally counter with nil io value"];
    }
    if (nnIntResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create tally counter instance"
                                      key:@"nnInt io value fail"
                                otherFail:nnIntResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJTallyCounter alloc] initWithCountValue:nnIntResult.value]];
}

- (nonnull instancetype)initWithCountValue:(nonnull ADJNonNegativeInt *)countValue {
    self = [super init];
    
    _countValue = countValue;
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nonnull instancetype)zeroInstance {
    static dispatch_once_t zeroInstanceToken;
    static id zeroInstance;
    dispatch_once(&zeroInstanceToken, ^{
        zeroInstance = [[self alloc] initWithCountValue:[ADJNonNegativeInt instanceAtZero]];
    });
    return zeroInstance;
}

+ (nonnull instancetype)oneInstance {
    static dispatch_once_t oneInstanceToken;
    static id oneInstance;
    dispatch_once(&oneInstanceToken, ^{
        oneInstance = [[self alloc] initWithCountValue:[ADJNonNegativeInt instanceAtOne]];
    });
    return oneInstance;
}

#pragma mark Public API
- (nonnull ADJTallyCounter *)generateIncrementedCounter {
    return [[ADJTallyCounter alloc] initWithCountValue:
            [[ADJNonNegativeInt alloc] initWithUIntegerValue:
             self.countValue.uIntegerValue + 1]];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    return [self.countValue toParamValue];
}

#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return [self.countValue toIoValue];
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // can return self since it's immutable
    return self;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [self.countValue description];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;
    
    hashCode = ADJHashCodeMultiplier * hashCode + [self.countValue hash];
    
    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ADJTallyCounter class]]) {
        return NO;
    }
    
    ADJTallyCounter *other = (ADJTallyCounter *)object;
    return [ADJUtilObj objectEquals:self.countValue other:other.countValue];
}

@end
