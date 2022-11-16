//
//  ADJV4FilesData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4FilesData.h"

#import "ADJUtilSys.h"
#import "ADJAdjustLogMessageData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJV4ActivityState *v4ActivityState;
 @property (nullable, readonly, strong, nonatomic) ADJV4Attribution *v4Attribution;
 @property (nullable, readonly, strong, nonatomic) NSArray<ADJV4ActivityPackage *> *v4ActivityPackageArray;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSString *> *v4SessionCallbackParameters;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSString *> *v4SessionPartnerParameters;
 */

@implementation ADJV4FilesData
#pragma mark Instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];
    
    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"AIActivityState"];
    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"ADJActivityState"];
    _v4ActivityState = [ADJV4FilesData readObjectWithFileName:@"AdjustIoActivityState"
                                                   objectName:@"Activity state"
                                                        class:[ADJV4ActivityState class]
                                                       logger:logger];
    
    [NSKeyedUnarchiver setClass:[ADJV4Attribution class] forClassName:@"ADJAttribution"];
    _v4Attribution = [ADJV4FilesData readObjectWithFileName:@"AdjustIoAttribution"
                                                 objectName:@"Attribution"
                                                      class:[ADJV4Attribution class]
                                                     logger:logger];
    
    [NSKeyedUnarchiver setClass:[ADJV4ActivityPackage class] forClassName:@"ADJActivityPackage"];
    _v4ActivityPackageArray = [ADJV4FilesData readObjectWithFileName:@"AdjustIoPackageQueue"
                                                          objectName:@"Package queue"
                                                               class:[NSArray class]
                                                              logger:logger];
    
    _v4SessionCallbackParameters =
    [ADJV4FilesData readObjectWithFileName:@"AdjustSessionCallbackParameters"
                                objectName:@"Session Callback parameters"
                                     class:[NSDictionary class]
                                    logger:logger];
    
    _v4SessionPartnerParameters =
    [ADJV4FilesData readObjectWithFileName:@"AdjustSessionPartnerParameters"
                                objectName:@"Session Partner parameters"
                                     class:[NSDictionary class]
                                    logger:logger];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
+ (nullable id)readObjectWithFileName:(nonnull NSString *)fileName
                           objectName:(nonnull NSString *)objectName
                                class:(nonnull Class)classToRead
                               logger:(nonnull ADJLogger *)logger {
    // Try to read from Application Support directory first.
    NSString *_Nullable appSupportFilePath = [ADJUtilSys getFilePathInAppSupportDir:fileName];
    
    id _Nullable appSupportReadObject =
    [self readObjectWithFilePath:appSupportFilePath
                        fileName:fileName
                      objectName:objectName
                           class:classToRead
                          logger:logger];
    
    if (appSupportReadObject != nil) {
        return appSupportReadObject;
    }
    
    // If in here, for some reason, reading of file from Application Support folder failed.
    // Let's check the Documents folder.
    NSString *_Nullable documentsFilePath = [ADJUtilSys getFilePathInDocumentsDir:fileName];
    
    id _Nullable documentsReadObject =
    [self readObjectWithFilePath:documentsFilePath
                        fileName:fileName
                      objectName:objectName
                           class:classToRead
                          logger:logger];
    
    return documentsReadObject;
}

+ (nullable id)readObjectWithFilePath:(nullable NSString *)filePath
                             fileName:(nonnull NSString *)fileName
                           objectName:(nonnull NSString *)objectName
                                class:(nonnull Class)classToRead
                               logger:(nonnull ADJLogger *)logger {
    if (filePath == nil) {
        [logger debugDev:@"Cannot decode object without file path"
                     key:@"objectName"
                   value:objectName
               issueType:ADJIssueStorageIo];
        return nil;
    }
    
    @try {
        id _Nullable objectRead = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (objectRead == nil) {
            [logger debugDev:@"Cannot decode object"
                        key1:@"objectName"
                      value1:objectName
                        key2:@"filePath"
                      value2:filePath
                   issueType:ADJIssueStorageIo];
            return nil;
        }
        
        if (! [objectRead isKindOfClass:classToRead]) {
            [logger debugDev:@"Cannot cast object"
                        key1:@"objectName"
                      value1:objectName
                        key2:@"filePath"
                      value2:filePath
                   issueType:ADJIssueStorageIo];
            return nil;
        }
        
        return objectRead;
    } @catch (NSException *ex) {
        [logger logWithInput:
             [[ADJInputLogMessageData alloc]
              initWithMessage:@"Exception from reading object from file"
              level:ADJAdjustLogLevelDebug
              issueType:ADJIssueStorageIo
              nsError:nil
              nsException:ex
              messageParams:[NSDictionary dictionaryWithObjectsAndKeys:
                             objectName, @"objectName",
                             filePath, @"filePath", nil]]];
    }
    
    return nil;
}

@end
