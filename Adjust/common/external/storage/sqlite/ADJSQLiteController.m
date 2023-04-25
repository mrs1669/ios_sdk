//
//  ADJSQLiteController.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteController.h"

#import "ADJPublisherBase.h"
#import "ADJUtilSys.h"
#import "ADJUtilF.h"
#import "ADJV4RestMigration.h"
#import "ADJV4FilesData.h"
#import "ADJV4UserDefaultsData.h"
#import "ADJConstants.h"
#import "ADJConstantsSys.h"
#import "ADJUtilUserDefaults.h"
#import "ADJUtilFiles.h"

#pragma mark Private class
@interface ADJSQLiteStorageAggregator : ADJPublisherBase<id<ADJSQLiteStorage>> @end
@implementation ADJSQLiteStorageAggregator @end

#pragma mark Fields
#pragma mark - ADJSQLiteDatabaseProvider
/* ADJSQLiteDatabaseProvider.h
 @property (nonnull, readonly, strong, nonatomic) ADJSQLiteDb *sqliteDb;
 */
#pragma mark - Private constants
static NSUInteger const kDatabaseVersion        = 5000; // v5.00.0
NSString * const kAdjustPrimaryInstanceIdKey    = @"AdjustPrimaryInstanceId";

@interface ADJSQLiteController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSQLiteStorageAggregator *sqliteStorageAggregator;
@property (nonnull, readonly, strong, nonatomic) ADJV4RestMigration *v4RestMigration;
@property (nonnull, readonly, strong, nonatomic) ADJInstanceIdData *instanceId;
@end

@implementation ADJSQLiteController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                   instanceId:(nonnull ADJInstanceIdData *)instanceId
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"SQLiteController"];
    _instanceId = instanceId;
    _sqliteStorageAggregator = [[ADJSQLiteStorageAggregator alloc] initWithoutSubscriberProtocol];
    
    _v4RestMigration = [[ADJV4RestMigration alloc] initWithLoggerFactory:loggerFactory
                                                              instanceId:instanceId];

    _sqliteDb = [[ADJSQLiteDb alloc] initWithLoggerFactory:loggerFactory];
    return self;
}

#pragma mark Public API
- (void)addSqlStorage:(nonnull id<ADJSQLiteStorage>)sqlStorage {
    [self.sqliteStorageAggregator addSubscriber:sqlStorage];
}

- (void)readAllIntoMemorySync {
    NSString *_Nullable dbPath = [self loadDbPath];
    if (dbPath == nil) { return; }

    BOOL dbLoaded = [self loadDbWithPath:dbPath];
    if (! dbLoaded) { return; }

    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [sqliteStorage readIntoMemorySync:self.sqliteDb];
    }];
}

#pragma mark Internal Methods
#pragma mark - loadDir
- (nullable NSString *)loadDbPath {
    NSString *_Nullable adjustAppSupportDirPath = [self loadAdjustAppSupportDir];
    if (adjustAppSupportDirPath == nil) { return nil; }

    NSString *_Nonnull dbFilename = [self.instanceId toDbName];
    NSString *_Nonnull adjustAppSupportDirDbPath =
        [ADJUtilFiles filePathWithDir:adjustAppSupportDirPath filename:dbFilename];

    return adjustAppSupportDirDbPath;
}

- (nullable NSString *)loadAdjustAppSupportDir {
    NSString *_Nullable adjustAppSupportDirPath = [ADJUtilFiles adjustAppSupportDir];
    if (adjustAppSupportDirPath == nil) {
        [self.logger debugDev:@"Cannot obtain adjust app dir path"
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    ADJResult<NSNumber *> *_Nonnull dirCreatedResult =
        [ADJUtilFiles createDirWithPath:adjustAppSupportDirPath];
    if (dirCreatedResult.fail != nil) {
        [self.logger debugWithMessage:@"Cannot create dir"
                         builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
         {
            [logBuilder withFail:dirCreatedResult.fail
                           issue:ADJIssueStorageIo];
            [logBuilder withKey:@"adjust app support dir"
                    stringValue:adjustAppSupportDirPath];
            [logBuilder where:@"load adjust app support dir"];
        }];

        return nil;
    }

    [self.logger debugDev:@"Adjust app support dir loaded"
                      key:@"was dir created"
              stringValue:[ADJUtilF boolFormat:dirCreatedResult.value.boolValue]];

    return adjustAppSupportDirPath;
}

#pragma mark - loadDb
- (BOOL)loadDbWithPath:(nonnull NSString *)dbPath {
    BOOL dbFileExists = [ADJUtilFiles fileExistsWithPath:dbPath];
    [self.logger debugDev:@"Was db file found"
                      key:@"dbFileExists"
              stringValue:[ADJUtilF boolFormat:dbFileExists]];

    BOOL dbOpened = [self.sqliteDb openDbWithPath:dbPath];
    if (! dbOpened) {
        return NO;
    }

    [self migrateOpenedDb];

    return YES;
}

- (void)migrateOpenedDb {
    ADJNonNegativeInt *_Nonnull dbVersion = [self.sqliteDb dbVersion];

    if (dbVersion.uIntegerValue == kDatabaseVersion) {
        [self.logger debugDev:@"Same db version found, no migration needed"
                          key:@"db version"
                  stringValue:dbVersion.description];
        return;
    }

    if (dbVersion.uIntegerValue > kDatabaseVersion) {
        [self.logger debugDev:@"Future db version found, will use as old version"
                         key1:@"file db version"
                 stringValue1:dbVersion.description
                         key2:@"sdk db version"
                 stringValue2:[ADJUtilF uIntegerFormat:kDatabaseVersion]
                    issueType:ADJIssueStorageIo];
        return;
    }

    // TODO: consider doing migration in sql transaction?

    if (dbVersion.uIntegerValue == 0) {
        [self.logger debugDev:@"No previous db version found"];

        [self migrateNewDb];
    } else {
        [self.logger debugDev:@"Older db version found"
                         key1:@"file db version"
                 stringValue1:dbVersion.description
                         key2:@"sdk db version"
                 stringValue2:[ADJUtilF uIntegerFormat:kDatabaseVersion]];

        [self migrateOldDbWithVersion:dbVersion];
    }

    [self.sqliteDb setDbVersion:kDatabaseVersion];
}

- (void)migrateNewDb {
    [self createTables];

    [self migratePrimaryInstance];
}

- (void)createTables {
    [self.logger debugDev:@"Creating database tables"];

    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [self.sqliteDb executeStatements:[sqliteStorage sqlStringForOnCreate]];
    }];

    [self.logger debugDev:@"All database tables created"];
}

- (void)migratePrimaryInstance {
    NSString *_Nullable readUserDefaultsPrimaryInstanceIdString =
        [self readUserDefaultsPrimaryInstanceId];
    if (readUserDefaultsPrimaryInstanceIdString != nil) {
        if ([self isPrimaryInstanceWithReadIdString:readUserDefaultsPrimaryInstanceIdString]) {
            [self.logger debugDev:
             @"Unexpected to find the same instance as primary already migrated."
             " Will not try to migrate again"
                        issueType:ADJIssueStorageIo];
        } else {
            [self.logger debugDev:
             @"Will not migrate, since a previous primary instance already did"
                              key:@"primary instance id"
                      stringValue:readUserDefaultsPrimaryInstanceIdString];
        }
        return;
    }

    BOOL isPrimaryInstance = [self isPrimaryInstance];
    if (! isPrimaryInstance) { return; }

    ADJOptionalFailsNN<ADJV4FilesData *> *_Nonnull v4FilesDataWithOptFails =
        [ADJV4FilesData readV4Files];
    for (ADJResultFail *_Nonnull optionalFail in v4FilesDataWithOptFails.optionalFails) {
        [self.logger debugDev:@"Failed with an optional value when reading v4 files"
                   resultFail:optionalFail
                    issueType:ADJIssueStorageIo];
    }

    ADJV4UserDefaultsData *_Nonnull v4UserDefaultsData =
        [[ADJV4UserDefaultsData alloc] initByReadingAll];

    // publish v4 migrate each storage instance
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [sqliteStorage migrateFromV4WithV4FilesData:v4FilesDataWithOptFails.value
                                 v4UserDefaultsData:v4UserDefaultsData];
    }];

    [self.v4RestMigration migrateFromV4WithV4FilesData:v4FilesDataWithOptFails.value
                                    v4UserDefaultsData:v4UserDefaultsData];

    [self markUserDefaultsPrimaryInstanceId];
    // TODO: Maybe we would like to delete all v4 data after
}

- (BOOL)isPrimaryInstance {
    NSString *_Nullable readInfoPlistPrimaryInstanceIdString =
        [self readInfoPlistPrimaryInstanceId];
    if (readInfoPlistPrimaryInstanceIdString != nil) {
        return [self isPrimaryInstanceWithReadIdString:readInfoPlistPrimaryInstanceIdString];
    }

    if (self.instanceId.isFirstInstance) {
        [self.logger debugDev:@"Will be used as the instance to migrate"
         " , since it was the first one and without any configured primary instance"];

        return YES;
    } else {
        [self.logger debugDev:@"Will not be used as the instance to migrate"
         " , since it was not the first one and without any configured primary instance"];

        return NO;
    }
}

- (nullable NSString *)readInfoPlistPrimaryInstanceId {
    NSDictionary<NSString *, id> *_Nullable infoDictionary =
        [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary == nil) { return nil; }

    id _Nullable primaryInstanceId =
        [infoDictionary objectForKey:ADJUserDefaultsPrimaryInstanceIdKey];
    if (primaryInstanceId == nil) { return nil;}

    if (! [primaryInstanceId isKindOfClass:[NSString class]]) { return nil; }

    return (NSString *)primaryInstanceId;
}

- (BOOL)isPrimaryInstanceWithReadIdString:(nonnull NSString *)readInstanceIdString {
    return [readInstanceIdString isEqualToString:self.instanceId.idString];
}

- (nullable NSString *)readUserDefaultsPrimaryInstanceId {
    return [ADJUtilUserDefaults stringWithKey:ADJUserDefaultsPrimaryInstanceIdKey];
}

- (void)markUserDefaultsPrimaryInstanceId {
    [ADJUtilUserDefaults setStringValue:self.instanceId.idString
                                    key:ADJUserDefaultsPrimaryInstanceIdKey];
}

- (void)migrateOldDbWithVersion:(nonnull ADJNonNegativeInt *)oldDbVersion {
    [self.logger debugDev:@"Upgrading database"
                     key1:@"old version"
             stringValue1:oldDbVersion.description
                     key2:@"new version"
             stringValue2:[ADJUtilF uIntegerFormat:kDatabaseVersion]];

    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        NSString *_Nullable sqlStringForOnUpgrade =
            [sqliteStorage sqlStringForOnUpgrade:oldDbVersion];

        if (sqlStringForOnUpgrade == nil) {
            [self.logger debugDev:@"Not upgrading sqlite storage"
                              key:@"storage description"
                      stringValue:sqliteStorage.description];
            return;
        }

        [self.logger debugDev:@"Upgrading sqlite storage"
                          key:@"sqlStringForOnUpgrade"
                  stringValue:sqlStringForOnUpgrade];

        [self.sqliteDb executeStatements:sqlStringForOnUpgrade];
    }];
}

@end
