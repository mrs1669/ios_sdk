//
//  ADJLocalThreadController.h
//  Adjust
//
//  Created by Pedro Silva on 06.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJLocalIdOutside;

NS_ASSUME_NONNULL_END

@interface ADJLocalThreadController : NSObject
// instantiation
+ (nonnull ADJLocalThreadController *)instance;

- (nullable instancetype)init NS_UNAVAILABLE;

+ (void)teardownSingleton;

// public api
- (nullable NSString *)localId;
- (nonnull NSString *)localIdOrOutside;

- (nonnull NSString *)setNextLocalIdWithSerialDispatchQueue:(nonnull dispatch_queue_t)dispachQueue;

- (nonnull NSString *)setNextLocalIdInConcurrentThread;
- (void)removeLocalIdInConcurrentThread;

@end
