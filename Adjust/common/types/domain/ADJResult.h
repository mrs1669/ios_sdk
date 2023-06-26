//
//  ADJResult.h
//  Adjust
//
//  Created by Pedro Silva on 01.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJResultFail.h"

@interface ADJResult<V> : NSObject
// public properties
@property (nullable, readonly, strong, nonatomic) V value;
@property (readonly, assign, nonatomic) BOOL wasInputNil;
@property (nullable, readonly, strong, nonatomic) ADJResultFail *fail;
@property (nullable, readonly, strong, nonatomic) ADJResultFail *failNonNilInput;

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;

+ (nonnull ADJResult<V> *)okWithValue:(nonnull V)value;

+ (nonnull ADJResult<V> *)nilInputWithMessage:(nonnull NSString *)nilInputMessage;

+ (nonnull ADJResult<V> *)failWithMessage:(nonnull NSString *)failMessage;
+ (nonnull ADJResult<V> *)failWithMessage:(nonnull NSString *)failMessage
                                      key:(nonnull NSString *)key
                              stringValue:(nonnull NSString *)stringValue;
+ (nonnull ADJResult<V> *)failWithMessage:(nonnull NSString *)failMessage
                                      key:(nonnull NSString *)key
                                otherFail:(nonnull ADJResultFail *)otherFail;
+ (nonnull ADJResult<V> *)failWithMessage:(nonnull NSString *)failMessage
                                    error:(nullable NSError *)error;
+ (nonnull ADJResult<V> *)failWithMessage:(nonnull NSString *)failMessage
                                exception:(nullable NSException *)exception;
+ (nonnull ADJResult<V> *)
    failWithMessage:(nonnull NSString *)failMessage
    wasInputNil:(BOOL)wasInputNil
    builderBlock:(void (^ _Nonnull NS_NOESCAPE)(ADJResultFailBuilder *_Nonnull resultFailBuilder))
        builderBlock;

@end
