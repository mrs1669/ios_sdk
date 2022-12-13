//
//  ADJLocalThreadController.m
//  Adjust
//
//  Created by Pedro Silva on 06.11.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLocalThreadController.h"

#import "ADJAtomicTallyCounter.h"
#import "ADJConstantsSys.h"
#import "ADJUtilF.h"


#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJLocalIdOutside = @"0";

#pragma mark - Private constants
static NSString *const kLocalIdKey = @"adj_localId";

#pragma mark - Static private properties
static ADJLocalThreadController *localThreadControllerInstance = nil;
static dispatch_once_t localThreadControllerOnceToken = 0;

@interface ADJLocalThreadController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJAtomicTallyCounter *atomicTallyCounter;

@end

@implementation ADJLocalThreadController
#pragma mark Instantiation
+ (nonnull ADJLocalThreadController *)instance {
    // add syncronization for testing teardown
#ifdef DEBUG
    @synchronized ([ADJLocalThreadController class]) {
#endif
        dispatch_once(&localThreadControllerOnceToken, ^{
            localThreadControllerInstance = [[ADJLocalThreadController alloc] initPrivate];
        });
        return localThreadControllerInstance;
#ifdef DEBUG
    }
#endif
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)teardownSingleton {
    @synchronized ([ADJLocalThreadController class]) {
        localThreadControllerOnceToken = 0;
        localThreadControllerInstance = nil;
    }
}

#pragma mark - Private Constructors
- (nonnull instancetype)initPrivate {
    self = [super init];

    _atomicTallyCounter = [[ADJAtomicTallyCounter alloc] initSeqCstMemoryOrderStartingAtOne];

    return self;
}

#pragma mark Public API
- (nullable NSString *)localId {
    void *_Nullable localIdVoid = dispatch_get_specific(kLocalIdKey.UTF8String);
    if (localIdVoid != NULL) {
        return [NSString stringWithUTF8String:(const char *_Nonnull)localIdVoid];
    }

    return [[[NSThread currentThread] threadDictionary] objectForKey:kLocalIdKey];
}

- (nonnull NSString *)localIdOrOutside {
    NSString *_Nullable localId = [self localId];
    return localId == nil ? ADJLocalIdOutside : localId;
}

- (nonnull NSString *)setNextLocalIdWithSerialDispatchQueue:(nonnull dispatch_queue_t)dispachQueue {
    NSUInteger nextLocalIdUInt = [self.atomicTallyCounter incrementAndGetPreviousValue];
    NSString *_Nonnull nextLocalNsString = [ADJUtilF uIntegerFormat:nextLocalIdUInt];
    // todo check if value that is being pointed at is still there or is cleaned
    dispatch_queue_set_specific(dispachQueue,
                                kLocalIdKey.UTF8String,
                                (void *)nextLocalNsString.UTF8String,
                                NULL);
    return nextLocalNsString;
}

- (nonnull NSString *)setNextLocalIdInConcurrentThread {
    NSUInteger nextLocalIdUInt = [self.atomicTallyCounter incrementAndGetPreviousValue];
    NSString *_Nonnull nextLocalNsString = [ADJUtilF uIntegerFormat:nextLocalIdUInt];

    NSMutableDictionary *_Nonnull threadDictionary = [[NSThread currentThread] threadDictionary];
    [threadDictionary setObject:nextLocalNsString forKey:kLocalIdKey];

    return nextLocalNsString;
}

- (void)removeLocalIdInConcurrentThread {
    NSMutableDictionary *_Nonnull threadDictionary = [[NSThread currentThread] threadDictionary];
    [threadDictionary removeObjectForKey:kLocalIdKey];
}

@end
