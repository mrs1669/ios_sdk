//
//  ADJSQLiteDb.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteDb.h"

#import <sqlite3.h>

#import "ADJSQLiteStatement.h"
#import "ADJUtilF.h"
#import "ADJAdjustLogMessageData.h"

#pragma mark Fields
@interface ADJSQLiteDb ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableSet<NSValue *> *openStatementValueSet;

@end

@implementation ADJSQLiteDb {
#pragma mark - Unmanaged variables
    sqlite3* _sqlite3;
}

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"SQLiteDb"];

    _openStatementValueSet = [[NSMutableSet alloc] init];

    return self;
}

#pragma mark Public API
- (nonnull ADJNonNegativeInt *)dbVersion {
    [self beginTransaction];

    ADJSQLiteStatement *_Nullable queryStatement =
    [self prepareStatementWithSqlString:@"PRAGMA user_version;"];

    if (queryStatement == nil) {
        [self.logger debugDev:@"Could not prepare statement to get db version"
                    issueType:ADJIssueStorageIo];
        [self rollback];
        return [ADJNonNegativeInt instanceAtZero];
    }

    BOOL readValue = [queryStatement nextInQueryStatementWithLogger:self.logger];

    if (! readValue) {
        [self.logger debugDev:@"Could not read value from query statement to get db version"];
        [queryStatement closeStatement];
        [self rollback];
        return [ADJNonNegativeInt instanceAtZero];
    }

    NSNumber *dbVersionNsNumber = [queryStatement numberIntForColumnIndex:0];
    ADJNonNegativeInt *_Nullable dbVersion =
        [ADJNonNegativeInt instanceFromIntegerNumber:dbVersionNsNumber
                                              logger:self.logger];
    if (dbVersion == nil) {
        [self.logger debugDev:@"Could not get number value from query to get db version"];
        [queryStatement closeStatement];
        [self rollback];
        return [ADJNonNegativeInt instanceAtZero];
    }

    [queryStatement closeStatement];
    [self commit];

    return dbVersion;
}

- (void)setDbVersion:(int)dbVersion {
    [self beginTransaction];

    ADJSQLiteStatement *_Nullable updateStatement =
    [self prepareStatementWithSqlString:
     [NSString stringWithFormat:@"PRAGMA user_version = %@",
      [ADJUtilF intFormat:dbVersion]]];

    if (updateStatement == nil) {
        [self.logger debugDev:@"Could not prepare statement to update db version"
                    issueType:ADJIssueStorageIo];
        [self rollback];
        return;
    }

    BOOL updateValue = [updateStatement executeUpdatePreparedStatementWithLogger:self.logger];

    if (! updateValue) {
        [self.logger debugDev:@"Could not update value from update statement to set db version"
                    issueType:ADJIssueStorageIo];
        [updateStatement closeStatement];
        [self rollback];
        return;
    }

    [updateStatement closeStatement];
    [self commit];
}

- (BOOL)openDbWithPath:(nonnull NSString *)dbPath {
    if (_sqlite3) {
        [self.logger debugDev:@"sqlite3 already open"
                    issueType:ADJIssueStorageIo];
        return NO;
    }

    /*
     // FULLMUTEX serializes connections, needed for close from outer thread
     int openFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX;

     int errCode = sqlite3_open_v2(self.databasePath.fileSystemRepresentation,
     &_sqlite3,
     openFlags,
     NULL);
     */
    int errCode = sqlite3_open(dbPath.fileSystemRepresentation, &_sqlite3);
    if(errCode != SQLITE_OK) {
        [self.logger debugDev:@"sqlite3_open error"
                          key:@"errCode"
                        value:[ADJUtilF intFormat:errCode]
                    issueType:ADJIssueStorageIo];
        return NO;
    }

    return YES;
}

- (BOOL)beginTransaction {
    return [self executeUpdate:@"begin exclusive transaction"];
}

- (BOOL)commit {
    return [self executeUpdate:@"commit transaction"];
}

- (BOOL)rollback {
    return [self executeUpdate:@"rollback transaction"];
}

// adapted from https://github.com/ccgus/fmdb/blob/2.7.4/src/fmdb/FMDatabase.m#L210
- (void)close {
    sqlite3 *localStrongSqlite3 = _sqlite3;
    _sqlite3 = NULL;
    if (! localStrongSqlite3) {
        [self.logger debugDev:@"Cannot close, since it is already closed"];
        return;
    }

    [self closeOpenStatements];
    [self closeWithSqliteDB:localStrongSqlite3];
}

- (BOOL)executeStatements:(nonnull NSString *)sqlString {
    sqlite3 *localStrongSqlite3 = _sqlite3;
    if (! localStrongSqlite3) {
        return NO;
    }

    char *_Nullable errmsg = NULL;

    int returnCode = sqlite3_exec(localStrongSqlite3, sqlString.UTF8String, NULL, NULL, &errmsg);

    if (errmsg) {
        [self.logger debugDev:@"Error inserting batch"
                         key1:@"errmsg"
                       value1:[NSString stringWithCString:errmsg
                                                 encoding:NSASCIIStringEncoding]
                         key2:@"sqlString"
                       value2:sqlString
                    issueType:ADJIssueStorageIo];

        sqlite3_free(errmsg);
    }

    return (returnCode == SQLITE_OK);
}

- (nullable ADJSQLiteStatement *)prepareStatementWithSqlString:(nonnull NSString *)sqlString {
    sqlite3 *localStrongSqlite3 = _sqlite3;
    if (! localStrongSqlite3) {
        [self.logger debugDev:@"Cannot prepare statement from closed db"
                    issueType:ADJIssueStorageIo];
        return nil;
    }

    sqlite3_stmt *_Nullable statement = NULL;
    int returnCode =
    sqlite3_prepare_v2(localStrongSqlite3, sqlString.UTF8String, -1, &statement, 0);

    if (SQLITE_OK != returnCode) {
        [self.logger debugDev:@"Cannot prepare statement"
                messageParams:[NSDictionary dictionaryWithObjectsAndKeys:
                               sqlString, @"sql",
                               [ADJUtilF intFormat:returnCode], @"returnCode",
                               [self lastErrorMessage], @"lastErrorMessage", nil]
                    issueType:ADJIssueStorageIo];

        sqlite3_finalize(statement);
        return nil;
    }

    ADJSQLiteStatement *_Nonnull sqliteStatement =
        [[ADJSQLiteStatement alloc] initWithSqliteStatement:statement
                                                  sqlString:sqlString
                                    sqliteDbMessageProvider:self];

    [self.openStatementValueSet addObject:[NSValue valueWithNonretainedObject:sqliteStatement]];

    return sqliteStatement;
}

- (BOOL)executeUpdate:(nonnull NSString *)sqlUpdateString {
    ADJSQLiteStatement *_Nullable sqliteStatement =
    [self prepareStatementWithSqlString:sqlUpdateString];

    if (sqliteStatement == nil) {
        return NO;
    }

    BOOL success = [sqliteStatement
                    executeUpdatePreparedStatementWithLogger:self.logger];

    [sqliteStatement closeStatement];

    return success;
}

#pragma mark - ADJSQLiteDbMessageProvider
- (nonnull NSString *)lastErrorMessage {
    sqlite3 *localStrongSqlite3 = _sqlite3;
    if (! localStrongSqlite3) {
        return @"Closed db";
    }

    const char *_Nullable errMsg = sqlite3_errmsg(localStrongSqlite3);
    if (errMsg) {
        return [NSString stringWithUTF8String:errMsg];
    } else {
        return @"Without last error message";
    }
}

- (void)statementClosed:(nonnull ADJSQLiteStatement *)statement {
    NSValue *statementValue = [NSValue valueWithNonretainedObject:statement];

    [self.openStatementValueSet removeObject:statementValue];
}


#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    [self close];
}

#pragma mark - NSObject
- (void)dealloc {
    [self close];
}

#pragma mark Internal Methods
- (void)closeOpenStatements {
    //Copy the set so we don't get mutation errors
    NSSet *_Nonnull openStatementValueSetCopy = [self.openStatementValueSet copy];

    for (NSValue *_Nonnull openStatementValue in openStatementValueSetCopy) {
        ADJSQLiteStatement *_Nullable openStatement =
        (ADJSQLiteStatement *)[openStatementValue pointerValue];

        if (openStatement != nil) {
            [openStatement closeStatement];
        }
    }
}

- (void)closeWithSqliteDB:(nonnull sqlite3 *)sqliteDB {
    /*
     sqlite3_stmt *_Nullable statement = NULL;
     int stmtReturnCode =
     sqlite3_prepare_v2(localStrongSqlite3, "rollback transaction", -1, &statement, 0);
     if (SQLITE_OK == stmtReturnCode) {
     sqlite3_step(statement);
     }
     sqlite3_finalize(statement);
     */
    int  returnCode;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;

    do {
        retry = NO;

        [self.logger debugDev:@"sqlite3_close call"];
        returnCode = sqlite3_close(sqliteDB);

        if (SQLITE_BUSY == returnCode || SQLITE_LOCKED == returnCode) {
            [self.logger debugDev:@"sqlite3_close was busy or locked"];

            if (! triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;

                sqlite3_stmt *_Nullable pStmt;

                while ((pStmt = sqlite3_next_stmt(sqliteDB, nil)) != 0) {
                    [self.logger debugDev:@"Closing leaked statement"];

                    sqlite3_finalize(pStmt);

                    retry = YES;
                }
            }
        } else if (SQLITE_OK != returnCode) {
            [self.logger debugDev:@"error closing db"
                              key:@"returnCode"
                            value:[ADJUtilF intFormat:returnCode]
                        issueType:ADJIssueStorageIo];
        }
    }
    while (retry);
}

@end



