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

#pragma mark Fields
#pragma mark - Protected properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *databasePath;
 */

@interface ADJSQLiteDb ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSMutableSet<NSValue *> *openStatementValueSet;

@end

@implementation ADJSQLiteDb {
#pragma mark - Unmanaged variables
    sqlite3* _sqlite3;
}
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                                 databasePath:(nullable NSString *)databasePath
{
    self = [super initWithLoggerFactory:loggerFactory source:@"SQLiteDb"];
    _databasePath = databasePath;

    _openStatementValueSet = [[NSMutableSet alloc] init];

    return self;
}

#pragma mark Public API
- (int)dbVersion {
    [self beginTransaction];

    ADJSQLiteStatement *_Nullable queryStatement =
        [self prepareStatementWithSqlString:@"PRAGMA user_version;"];

    if (queryStatement == nil) {
        [self.logger error:@"Could not prepare statement to get db version"];
        [self rollback];
        return 0;
    }

    BOOL readValue = [queryStatement nextInQueryStatementWithLogger:self.logger];

    if (! readValue) {
        [self.logger debug:@"Could not read value "
            "from query statement to get db version"];
        [queryStatement closeStatement];
        [self rollback];
        return 0;
    }

    NSNumber *dbVersionNumber = [queryStatement numberIntForColumnIndex:0];
    if (dbVersionNumber == nil) {
        [self.logger debug:@"Could not get number value "
            "from query to get db version"];
        [queryStatement closeStatement];
        [self rollback];
        return 0;
    }

    [queryStatement closeStatement];
    [self commit];

    return [dbVersionNumber intValue];
}

- (void)setDbVersion:(int)dbVersion {
    [self beginTransaction];

    ADJSQLiteStatement *_Nullable updateStatement =
        [self prepareStatementWithSqlString:
            [NSString stringWithFormat:@"PRAGMA user_version = %@",
                [ADJUtilF intFormat:dbVersion]]];

    if (updateStatement == nil) {
        [self.logger error:@"Could not prepare statement to update db version"];
        [self rollback];
        return;
    }

    BOOL updateValue = [updateStatement executeUpdatePreparedStatementWithLogger:self.logger];

    if (! updateValue) {
        [self.logger debug:@"Could not update value "
            "from update statement to set db version"];
        [updateStatement closeStatement];
        [self rollback];
        return;
    }

    [updateStatement closeStatement];
    [self commit];
}

- (BOOL)openDb {
    if (_sqlite3) {
        [self.logger error:@"sqlite3 already open"];
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
    int errCode = sqlite3_open(self.databasePath.fileSystemRepresentation, &_sqlite3);
    if(errCode != SQLITE_OK) {
        [self.logger error:@"sqlite3_open error with result code: %d", errCode];
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
        [self.logger debug:@"Cannot close, since it is already closed"];
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

    char *_Nullable errmsg = nil;

    int returnCode = sqlite3_exec(localStrongSqlite3, sqlString.UTF8String, NULL, NULL, &errmsg);

    if (errmsg) {
        [self.logger error:@"Error inserting batch: %s", errmsg];

        sqlite3_free(errmsg);
    }

    return (returnCode == SQLITE_OK);
}

- (nullable ADJSQLiteStatement *)prepareStatementWithSqlString:(nonnull NSString *)sqlString {
    sqlite3 *localStrongSqlite3 = _sqlite3;
    if (! localStrongSqlite3) {
        [self.logger error:@"Cannot prepare statement from closed db"];
        return nil;
    }

    sqlite3_stmt *_Nullable statement = NULL;
    int returnCode =
        sqlite3_prepare_v2(localStrongSqlite3, sqlString.UTF8String, -1, &statement, 0);

    if (SQLITE_OK != returnCode) {
        [self.logger error:@"Cannot prepare statement from sql: %@, with code: %d and message: %@",
            sqlString, returnCode, [self lastErrorMessage]];

        sqlite3_finalize(statement);
        return nil;
    }

    ADJSQLiteStatement *_Nonnull sqliteStatement =
        [[ADJSQLiteStatement alloc] initWithSqliteStatement:statement
                                                   sqlString:sqlString
                                      sqiteDbMessageProvider:self];

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

/*
#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    [self close];
}
*/
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

        [self.logger debug:@"sqlite3_close call"];
        returnCode = sqlite3_close(sqliteDB);

        if (SQLITE_BUSY == returnCode || SQLITE_LOCKED == returnCode) {
            [self.logger debug:@"sqlite3_close was busy or locked"];

            if (! triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;

                sqlite3_stmt *_Nullable pStmt;

                while ((pStmt = sqlite3_next_stmt(sqliteDB, nil)) != 0) {
                    [self.logger debug:@"Closing leaked statement"];

                    sqlite3_finalize(pStmt);

                    retry = YES;
                }
            }
        } else if (SQLITE_OK != returnCode) {
            [self.logger error:@"error closing db with result code: %d", returnCode];
        }
    }
    while (retry);
}

@end

