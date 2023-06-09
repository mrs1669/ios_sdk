//
//  ADJMainQueueTrackedPackages.m
//  Adjust
//
//  Created by Pedro Silva on 31.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJMainQueueTrackedPackages.h"

#import "ADJSessionPackageData.h"
#import "ADJSQLiteStorageQueueMetadataAction.h"
#import "ADJClickPackageData.h"
#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Private constants
static NSString *const kFirstSessionCountKey = @"firstSessionCount";
static NSString *const kAsaClickCountKey = @"asaClickCount";

@interface ADJMainQueueTrackedPackages ()
#pragma mark - Injected dependencies
@property (nonnull, readonly, strong, nonatomic) ADJMainQueueStorage *storage;

@end

@implementation ADJMainQueueTrackedPackages

// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    mainQueueStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"MainQueueTrackedPackages"];
    _storage = mainQueueStorage;

    return self;
}

#pragma mark Public API
- (nonnull ADJResult<ADJNonNegativeInt *> *)firstSessionCount {
    ADJNonEmptyString *_Nullable firstSessionCountIoValue =
        [[self.storage metadataMap] pairValueWithKey:kFirstSessionCountKey];

    return [ADJNonNegativeInt instanceFromIoDataValue:firstSessionCountIoValue];
}

- (nonnull ADJResult<ADJNonNegativeInt *> *)asaClickCount {
    ADJNonEmptyString *_Nullable asaClickCountIoValue =
        [[self.storage metadataMap] pairValueWithKey:kAsaClickCountKey];

    return [ADJNonNegativeInt instanceFromIoDataValue:asaClickCountIoValue];
}

- (nullable ADJSQLiteStorageActionBase *)
    incrementTrackedCountWithPackageToAdd:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
    sqliteStorageActionForAdd:(nullable ADJSQLiteStorageActionBase *)sqliteStorageActionForAdd
{
    ADJSQLiteStorageActionBase *_Nullable decoratedSqliteStorageAction =
        [self incrementFirstSessionCountWithPackageToAdd:sdkPackageDataToAdd
                               sqliteStorageActionForAdd:sqliteStorageActionForAdd];

    return [self incrementAsaClickCountWithPackageToAdd:sdkPackageDataToAdd
                              sqliteStorageActionForAdd:decoratedSqliteStorageAction];
}

- (nullable ADJSQLiteStorageActionBase *)decrementTrackedCountWithPackageToRemove:
    (nonnull id<ADJSdkPackageData>)sourceResponsePackage
{
    ADJSQLiteStorageActionBase *_Nullable decoratedSqliteStorageAction =
        [self decrementFirstSessionCountWithPackageToRemove:sourceResponsePackage
                                        sqliteStorageAction:nil];

    return [self decrementAsaClickCountWithPackageToRemove:sourceResponsePackage
                                       sqliteStorageAction:decoratedSqliteStorageAction];
}

+ (BOOL)isFirstSessionPackageWithData:(nullable id<ADJSdkPackageData>)sdkPackageData {
    if (sdkPackageData == nil
        || ! [sdkPackageData isKindOfClass:[ADJSessionPackageData class]])
    {
        return NO;
    }

    ADJSessionPackageData *_Nonnull sessionPackageData = (ADJSessionPackageData *)sdkPackageData;
    return [sessionPackageData isFirstSession];
}

+ (BOOL)isAsaClickPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData {
    if (sdkPackageData == nil
        || ! [sdkPackageData isKindOfClass:[ADJClickPackageData class]])
    {
        return NO;
    }

    ADJClickPackageData *_Nonnull clickPackageData = (ADJClickPackageData *)sdkPackageData;
    return [clickPackageData isAsaClick];
}

#pragma mark Internal Methods
#pragma mark - First Session Count Increment
- (nullable ADJSQLiteStorageActionBase *)
    incrementFirstSessionCountWithPackageToAdd:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
    sqliteStorageActionForAdd:(nullable ADJSQLiteStorageActionBase *)sqliteStorageActionForAdd
{
    if (! [ADJMainQueueTrackedPackages isFirstSessionPackageWithData:sdkPackageDataToAdd]) {
        return sqliteStorageActionForAdd;
    }

    ADJStringMap *_Nonnull currentMetadataMap = [self.storage metadataMap];

    ADJStringMapBuilder *_Nonnull metadataBuilder =
        [[ADJStringMapBuilder alloc] initWithStringMap:currentMetadataMap];

    ADJNonNegativeInt *_Nonnull newFirstSessionCount =
        [self incrementedFirstSessionCountWithMetadataMap:currentMetadataMap];

    [metadataBuilder addPairWithValue:[newFirstSessionCount toIoValue]
                                  key:kFirstSessionCountKey];

    ADJStringMap *_Nonnull updatedMetadaMap =
        [[ADJStringMap alloc] initWithStringMapBuilder:metadataBuilder];

    return [[ADJSQLiteStorageQueueMetadataAction alloc]
            initWithQueueStorage:self.storage
            metadataMap:updatedMetadaMap
            decoratedSQLiteStorageAction:sqliteStorageActionForAdd];
}

- (nonnull ADJNonNegativeInt *)incrementedFirstSessionCountWithMetadataMap:
    (nonnull ADJStringMap *)metadataMap
{
    ADJNonEmptyString *_Nullable currentIoValue =
        [metadataMap pairValueWithKey:kFirstSessionCountKey];

    if (currentIoValue == nil) {
        return [ADJNonNegativeInt instanceAtOne];
    }

    [self.logger debugDev:@"Previous first sesssion count found"
                      key:@"current First Session Count IoValue"
                    value:currentIoValue.stringValue
                issueType:ADJIssueUnexpectedInput];

    ADJResult<ADJNonNegativeInt *> *_Nonnull currentFirstSessionCountResult =
        [ADJNonNegativeInt instanceFromIoDataValue:currentIoValue];
    if (currentFirstSessionCountResult.fail != nil) {
        [self.logger debugDev:@"Invalid current first session count"
                   resultFail:currentFirstSessionCountResult.fail
                    issueType:ADJIssueStorageIo];
        return [ADJNonNegativeInt instanceAtOne];
    }

    return [[ADJNonNegativeInt alloc] initWithUIntegerValue:
            currentFirstSessionCountResult.value.uIntegerValue + 1];
}


#pragma mark - First Session Count Decrement
- (nullable ADJSQLiteStorageActionBase *)
    decrementFirstSessionCountWithPackageToRemove:
        (nonnull id<ADJSdkPackageData>)sourceResponsePackage
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    if (! [ADJMainQueueTrackedPackages isFirstSessionPackageWithData:sourceResponsePackage]) {
        return sqliteStorageAction;
    }

    ADJStringMap *_Nonnull currentMetadataMap = [self.storage metadataMap];

    ADJStringMapBuilder *_Nonnull metadataBuilder =
        [[ADJStringMapBuilder alloc] initWithStringMap:currentMetadataMap];

    ADJNonNegativeInt *_Nonnull newFirstSessionCount =
        [self decrementedFirstSessionCountWithMetadataMap:currentMetadataMap];

    [metadataBuilder addPairWithValue:[newFirstSessionCount toIoValue]
                                  key:kFirstSessionCountKey];

    ADJStringMap *_Nonnull updatedMetadaMap =
        [[ADJStringMap alloc] initWithStringMapBuilder:metadataBuilder];

    return [[ADJSQLiteStorageQueueMetadataAction alloc]
            initWithQueueStorage:self.storage
            metadataMap:updatedMetadaMap
            decoratedSQLiteStorageAction:sqliteStorageAction];
}

- (nonnull ADJNonNegativeInt *)decrementedFirstSessionCountWithMetadataMap:
    (nonnull ADJStringMap *)metadataMap
{
    ADJNonEmptyString *_Nullable currentIoValue =
        [metadataMap pairValueWithKey:kFirstSessionCountKey];

    if (currentIoValue == nil) {
        [self.logger debugWithMessage:@"Cannot decrement first session count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder) {
            [logBuilder withSubject:@"previous first session count"
                                why:@"not found in metadata map"];
            [logBuilder where:@"decremented first session count"];
            [logBuilder issue:ADJIssueStorageIo];
        }];
        return [ADJNonNegativeInt instanceAtZero];
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull currentFirstSessionCountResult =
        [ADJNonNegativeInt instanceFromIoDataValue:currentIoValue];
    if (currentFirstSessionCountResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot decrement first session count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"previous first session count"
                                why:@"failed to parse from io value"];
            [logBuilder where:@"decremented first session count"];
            [logBuilder withKey:@"io value"
                          value:currentIoValue.stringValue];
            [logBuilder withFail:currentFirstSessionCountResult.fail
                           issue:ADJIssueStorageIo];
        }];
        return [ADJNonNegativeInt instanceAtZero];
    }

    if (currentFirstSessionCountResult.value.uIntegerValue == 0) {
        [self.logger debugWithMessage:@"Cannot decrement first session count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"previous first session count"
                                why:@"was zero"];
            [logBuilder where:@"decremented first session count"];
            [logBuilder issue:ADJIssueStorageIo];
        }];
        return [ADJNonNegativeInt instanceAtZero];
    }

    return [[ADJNonNegativeInt alloc]
            initWithUIntegerValue:currentFirstSessionCountResult.value.uIntegerValue - 1];
}

#pragma mark - Asa Click Count Increment
- (nullable ADJSQLiteStorageActionBase *)
    incrementAsaClickCountWithPackageToAdd:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
    sqliteStorageActionForAdd:(nullable ADJSQLiteStorageActionBase *)sqliteStorageActionForAdd
{
    if (! [ADJMainQueueTrackedPackages isAsaClickPackageWithData:sdkPackageDataToAdd]) {
        return sqliteStorageActionForAdd;
    }

    ADJStringMap *_Nonnull currentMetadataMap = [self.storage metadataMap];

    ADJStringMapBuilder *_Nonnull metadataBuilder =
        [[ADJStringMapBuilder alloc] initWithStringMap:currentMetadataMap];

    ADJNonNegativeInt *_Nonnull newAsaClickCount =
        [self incrementedAsaClickCountWithMetadataMap:currentMetadataMap];

    [metadataBuilder addPairWithValue:[newAsaClickCount toIoValue]
                                  key:kAsaClickCountKey];

    ADJStringMap *_Nonnull updatedMetadaMap =
        [[ADJStringMap alloc] initWithStringMapBuilder:metadataBuilder];

    return [[ADJSQLiteStorageQueueMetadataAction alloc]
            initWithQueueStorage:self.storage
            metadataMap:updatedMetadaMap
            decoratedSQLiteStorageAction:sqliteStorageActionForAdd];
}

- (nonnull ADJNonNegativeInt *)incrementedAsaClickCountWithMetadataMap:
    (nonnull ADJStringMap *)metadataMap
{
    ADJNonEmptyString *_Nullable currentIoValue = [metadataMap pairValueWithKey:kAsaClickCountKey];
    if (currentIoValue == nil) {
        return [ADJNonNegativeInt instanceAtOne];
    }

    [self.logger debugDev:@"Previous asa click count found"
                      key:@"current Asa Click Count IoValue"
                    value:currentIoValue.stringValue
                issueType:ADJIssueUnexpectedInput];

    ADJResult<ADJNonNegativeInt *> *_Nonnull currentAsaClickCountResult =
        [ADJNonNegativeInt instanceFromIoDataValue:currentIoValue];

    if (currentAsaClickCountResult.fail != nil) {
        [self.logger debugDev:@"Invalid current asa click count when incrementing"
                   resultFail:currentAsaClickCountResult.fail
                    issueType:ADJIssueStorageIo];
        return [ADJNonNegativeInt instanceAtOne];
    }

    return [[ADJNonNegativeInt alloc] initWithUIntegerValue:
            currentAsaClickCountResult.value.uIntegerValue + 1];
}

#pragma mark - Asa Click Count Decrement
- (nullable ADJSQLiteStorageActionBase *)
    decrementAsaClickCountWithPackageToRemove:
        (nonnull id<ADJSdkPackageData>)sourceResponsePackage
    sqliteStorageAction:(nullable ADJSQLiteStorageActionBase *)sqliteStorageAction
{
    if (! [ADJMainQueueTrackedPackages isAsaClickPackageWithData:sourceResponsePackage]) {
        return sqliteStorageAction;
    }

    ADJStringMap *_Nonnull currentMetadataMap = [self.storage metadataMap];

    ADJStringMapBuilder *_Nonnull metadataBuilder =
        [[ADJStringMapBuilder alloc] initWithStringMap:currentMetadataMap];

    ADJNonNegativeInt *_Nonnull newAsaClickCount =
        [self decrementedAsaClickCountWithMetadataMap:currentMetadataMap];

    [metadataBuilder addPairWithValue:[newAsaClickCount toIoValue]
                                  key:kAsaClickCountKey];

    ADJStringMap *_Nonnull updatedMetadaMap =
        [[ADJStringMap alloc] initWithStringMapBuilder:metadataBuilder];

    return [[ADJSQLiteStorageQueueMetadataAction alloc]
            initWithQueueStorage:self.storage
            metadataMap:updatedMetadaMap
            decoratedSQLiteStorageAction:sqliteStorageAction];
}

- (nonnull ADJNonNegativeInt *)decrementedAsaClickCountWithMetadataMap:
    (nonnull ADJStringMap *)metadataMap
{
    ADJNonEmptyString *_Nullable currentIoValue =
        [metadataMap pairValueWithKey:kAsaClickCountKey];

    if (currentIoValue == nil) {
        [self.logger debugWithMessage:@"Cannot decrement asa click count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"previous asa click count"
                                why:@"not found in metadata map"];
            [logBuilder where:@"decremented asa click count"];
            [logBuilder issue:ADJIssueStorageIo];
        }];

        return [ADJNonNegativeInt instanceAtZero];
    }

    ADJResult<ADJNonNegativeInt *> *_Nonnull currentAsaClickCountResult =
        [ADJNonNegativeInt instanceFromIoDataValue:currentIoValue];

    if (currentAsaClickCountResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot decrement asa click count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"previous asa click count"
                                why:@"failed to parse from io value"];
            [logBuilder where:@"decremented asa click count"];
            [logBuilder withKey:@"io value"
                          value:currentIoValue.stringValue];
            [logBuilder withFail:currentAsaClickCountResult.fail
                           issue:ADJIssueStorageIo];
        }];

        return [ADJNonNegativeInt instanceAtZero];
    }

    if (currentAsaClickCountResult.value.uIntegerValue == 0) {
        [self.logger debugWithMessage:@"Cannot decrement asa click count"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withSubject:@"previous asa click count"
                                why:@"was zero"];
            [logBuilder where:@"decremented asa click count"];
            [logBuilder issue:ADJIssueStorageIo];
        }];
        return [ADJNonNegativeInt instanceAtZero];
    }

    return [[ADJNonNegativeInt alloc]
            initWithUIntegerValue:currentAsaClickCountResult.value.uIntegerValue - 1];
}

@end
