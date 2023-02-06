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
    self = [super initWithLoggerFactory:loggerFactory source:@"SQLiteController"];
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

    [self moveDbFileFromDocumentsDirWithDbFilename:dbFilename
                         adjustAppSupportDirDbPath:adjustAppSupportDirDbPath];

    return adjustAppSupportDirDbPath;
}
- (nullable NSString *)loadAdjustAppSupportDir {
    NSString *_Nullable adjustAppSupportDirPath = [ADJUtilFiles adjustAppSupportDir];
    if (adjustAppSupportDirPath == nil) {
        [self.logger debugDev:@"Cannot obtain adjust app dir path"
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    NSError *dirCreateError;
    BOOL dirCreated =
        [ADJUtilFiles createDirWithPath:adjustAppSupportDirPath
                               errorPtr:&dirCreateError];
    if (dirCreateError != nil) {
        [self.logger debugDev:@"Cannot create adjust app dir"
                      nserror:dirCreateError
                          key:@"adjust app dir path"
                        value:adjustAppSupportDirPath
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    [self.logger debugDev:@"Adjust app support dir loaded"
                      key:@"was dir created"
                    value:[ADJUtilF boolFormat:dirCreated]];

    return adjustAppSupportDirPath;
}

- (void)moveDbFileFromDocumentsDirWithDbFilename:(nonnull NSString *)dbFilename
                       adjustAppSupportDirDbPath:(nonnull NSString *)adjustAppSupportDirDbPath
{
    NSString *_Nullable documentsDbFilename = [ADJUtilFiles filePathInDocumentsDir:dbFilename];
    if (documentsDbFilename == nil) {
        [self.logger debugDev:@"Cannot obtain documents dir path"
                          key:@"db filename"
                        value:dbFilename];
        return;
    }

    NSError *dbFileMoveError;
    BOOL fileMoved =
        [ADJUtilFiles moveFileFromPath:documentsDbFilename
                                toPath:adjustAppSupportDirDbPath
                              errorPtr:&dbFileMoveError];

    if (dbFileMoveError != nil) {
        [self.logger debugDev:@"Cannot move db file from documents to app support dir"
                      nserror:dbFileMoveError
                          key:@"db filename"
                        value:dbFilename
                    issueType:ADJIssueStorageIo];
    } else {
        [self.logger debugDev:@"Db file tried to be moved from documents to app support dir"
                         key1:@"db filename"
                       value1:dbFilename
                         key2:@"was file moved"
                       value2:@(fileMoved).description];
    }
}

#pragma mark - loadDb
- (BOOL)loadDbWithPath:(nonnull NSString *)dbPath {
    BOOL dbFileExists = [ADJUtilFiles fileExistsWithPath:dbPath];
    [self.logger debugDev:@"Was db file found"
                      key:@"dbFileExists"
                    value:[ADJUtilF boolFormat:dbFileExists]];

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
                        value:dbVersion.description];
        return;
    }

    if (dbVersion.uIntegerValue > kDatabaseVersion) {
        [self.logger debugDev:@"Future db version found, will use as old version"
                         key1:@"file db version"
                       value1:dbVersion.description
                         key2:@"sdk db version"
                       value2:@(kDatabaseVersion).description
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
                       value1:dbVersion.description
                         key2:@"sdk db version"
                       value2:@(kDatabaseVersion).description];

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
                            value:readUserDefaultsPrimaryInstanceIdString];
        }
        return;
    }

    BOOL isPrimaryInstance = [self isPrimaryInstance];
    if (! isPrimaryInstance) { return; }

    ADJV4FilesData *_Nonnull v4FilesData = [[ADJV4FilesData alloc] initWithLogger:self.logger];
    ADJV4UserDefaultsData *_Nonnull v4UserDefaultsData =
        [[ADJV4UserDefaultsData alloc] initByReadingAll];

    // publish v4 migrate each storage instance
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [sqliteStorage migrateFromV4WithV4FilesData:v4FilesData
                                 v4UserDefaultsData:v4UserDefaultsData];
    }];

    [self.v4RestMigration migrateFromV4WithV4FilesData:v4FilesData
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

    if ([primaryInstanceId isKindOfClass:[NSString class]]) { return nil; }

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
                   value1:oldDbVersion.description
                     key2:@"new version"
                   value2:[ADJUtilF integerFormat:kDatabaseVersion]];

    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        NSString *_Nullable sqlStringForOnUpgrade =
            [sqliteStorage sqlStringForOnUpgrade:oldDbVersion];

        if (sqlStringForOnUpgrade == nil) {
            [self.logger debugDev:@"Not upgrading sqlite storage"
                              key:@"storage description"
                            value:sqliteStorage.description];
            return;
        }

        [self.logger debugDev:@"Upgrading sqlite storage"
                          key:@"sqlStringForOnUpgrade"
                        value:sqlStringForOnUpgrade];

        [self.sqliteDb executeStatements:sqlStringForOnUpgrade];
    }];
}

@end
