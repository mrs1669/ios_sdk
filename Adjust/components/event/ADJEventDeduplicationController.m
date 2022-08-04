//
//  ADJEventDeduplicationController.m
//  Adjust
//
//  Created by Aditi Agrawal on 02/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventDeduplicationController.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

@interface ADJEventDeduplicationController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic)
ADJEventDeduplicationStorage *eventDeduplicationStorageWeak;
@property (nonnull, readonly, strong, nonatomic)
ADJNonNegativeInt *maxCapacityEventDeduplication;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
NSMutableSet<NSString *> *deduplicationIdSet;

@end

@implementation ADJEventDeduplicationController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                    eventDeduplicationStorage:(nonnull ADJEventDeduplicationStorage *)eventDeduplicationStorage
                maxCapacityEventDeduplication:(nullable ADJNonNegativeInt *)maxCapacityEventDeduplication {
    self = [super initWithLoggerFactory:loggerFactory source:@"EventDeduplicationController"];
    _eventDeduplicationStorageWeak = eventDeduplicationStorage;
    
    if (maxCapacityEventDeduplication != nil) {
        _maxCapacityEventDeduplication = maxCapacityEventDeduplication;
        
        [self.logger debug:@"Overwriting max capacity event deduplication to %@",
         self.maxCapacityEventDeduplication];
    } else {
        _maxCapacityEventDeduplication =
        [[ADJNonNegativeInt alloc]
         initWithUIntegerValue:ADJDefaultMaxCapacityEventDeduplication];
        
        [self.logger debug:@"Falling back to default max capacity event deduplication of %@",
         self.maxCapacityEventDeduplication];
    }
    
    _deduplicationIdSet =
    [[NSMutableSet alloc]
     initWithCapacity:self.maxCapacityEventDeduplication.uIntegerValue];
    
    [self loadDeduplicationWithStorage:eventDeduplicationStorage];
    
    return self;
}

#pragma mark Public API
- (BOOL)ccContainsWithDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId {
    return [self.deduplicationIdSet containsObject:deduplicationId.stringValue];
}

- (nonnull ADJNonNegativeInt *)ccAddWithDeduplicationId:(nonnull ADJNonEmptyString *)deduplicationId {
    ADJEventDeduplicationStorage *_Nullable storage =
    self.eventDeduplicationStorageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot add deduplication id without a reference to storage"];
        return [ADJNonNegativeInt instanceAtZero];
    }
    
    if (self.maxCapacityEventDeduplication.uIntegerValue == 0) {
        [self.logger info:@"Cannot add deduplication id to the duplication list,"
         " because it has capacity for zero deduplication ids"];
        return [storage count];
    }
    
    if ([self ccContainsWithDeduplicationId:deduplicationId]) {
        [self.logger info:@"Cannot add deduplication id to the duplication list,"
         " because it already contains the same deduplication id"];
        return [storage count];
    }
    
    NSInteger excessDeduplicationIdsCount =
    [storage count].uIntegerValue - self.maxCapacityEventDeduplication.uIntegerValue;
    
    if (excessDeduplicationIdsCount >= 0) {
        [self.logger info:@"Event deduplication id list hit limit of %@."
         " It will remove enough of the oldest added deduplication ids"
         " before adding the new one",
         self.maxCapacityEventDeduplication];
        
        [self removeOldestDeduplicationIdsWithStorage:storage
                  oldestDeduplicationIdsToRemoveCount:excessDeduplicationIdsCount + 1];
    }
    
    ADJEventDeduplicationData *_Nonnull elementToEnqueue =
    [[ADJEventDeduplicationData alloc] initWithDeduplicationId:deduplicationId];
    
    [storage enqueueElementToLast:elementToEnqueue sqliteStorageAction:nil];
    [self.deduplicationIdSet addObject:deduplicationId.stringValue];
    
    return [storage count];
}

#pragma mark Internal Methods
- (void)loadDeduplicationWithStorage:(nonnull ADJEventDeduplicationStorage *)storage {
    NSInteger excessDeduplicationIdsCount =
    [storage count].uIntegerValue - self.maxCapacityEventDeduplication.uIntegerValue;
    
    if (excessDeduplicationIdsCount > 0) {
        [self.logger debug:@"Event deduplication id list was loaded with %@ ids above limit."
         " They will removed from oldest order",
         [ADJUtilF integerFormat:excessDeduplicationIdsCount]];
        [self removeOldestDeduplicationIdsWithStorage:storage
                  oldestDeduplicationIdsToRemoveCount:(NSUInteger)excessDeduplicationIdsCount];
    }
    
    NSDictionary<ADJNonNegativeInt *, ADJEventDeduplicationData *> *_Nonnull
    elementWithPositionList = [storage copyElementWithPositionList];
    
    for (ADJNonNegativeInt *_Nonnull elementPosition in elementWithPositionList) {
        ADJEventDeduplicationData *_Nonnull deduplicationIdElement =
        [elementWithPositionList objectForKey:elementPosition];
        
        if ([self.deduplicationIdSet containsObject:
             deduplicationIdElement.deduplicationId.stringValue])
        {
            [self.logger error:@"Found unexpected duplicated id in storage, removing it"];
            [storage removeElementByPosition:elementPosition];
        } else {
            [self.deduplicationIdSet
             addObject:deduplicationIdElement.deduplicationId.stringValue];
        }
    }
}

- (void)removeOldestDeduplicationIdsWithStorage:(nonnull ADJEventDeduplicationStorage *)storage
            oldestDeduplicationIdsToRemoveCount:(NSUInteger)oldestDeduplicationIdsToRemoveCount {
    if (oldestDeduplicationIdsToRemoveCount > [storage count].uIntegerValue) {
        [storage removeAllElements];
        [self.deduplicationIdSet removeAllObjects];
        return;
    }
    
    for (NSUInteger i = 0; i < oldestDeduplicationIdsToRemoveCount; i = i + 1) {
        if ([storage isEmpty]) {
            [self.logger error:@"Cannot remove more oldest deduplication ids"
             " when there are no more to remove"];
            return;
        }
        
        ADJEventDeduplicationData *_Nullable removedElement = [storage removeElementAtFront];
        
        if (removedElement == nil) {
            [self.logger error:@"Was not able to retrieve removed oldest deduplication id"
             " from storage"];
            continue;
        }
        
        [self.logger debug:@"Removed more oldest deduplication id in storage"];
        
        if (self.deduplicationIdSet.count == 0) {
            [self.logger error:@"Does not have any id in set, when it was expected"];
            continue;
        }
        
        BOOL containsElementInSet =
        [self.deduplicationIdSet containsObject:removedElement.deduplicationId.stringValue];
        
        if (! containsElementInSet) {
            [self.logger error:@"Cannot remove oldest deduplication id from set"
             " when it was not present"];
        }
        
        [self.deduplicationIdSet removeObject:removedElement.deduplicationId.stringValue];
        
        [self.logger debug:@"Removed more oldest deduplication id in set"];
    }
}

@end

